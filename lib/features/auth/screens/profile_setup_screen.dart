import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_test/features/auth/providers/auth_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  String? _localImagePath;
  bool isLoading = false;
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 60,
      );
      if (pickedFile != null) {
        setState(() {
          _localImagePath = pickedFile.path;
        });
      }
    } catch (e) {
      debugPrint("❌ Error picking image: $e");
    }
  }

  List<int> hmacSha256(List<int> key, String data) {
    return Hmac(sha256, key).convert(utf8.encode(data)).bytes;
  }

  String hexEncode(List<int> bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  Future<void> _saveAndContinue({bool isSkip = false}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    if (!isSkip && _localImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a profile picture or tap Skip.'),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      if (_localImagePath != null) {
        final String region = "sgp1";
        final String bucketName = "msquarefdc";

        final int timestamp = DateTime.now().millisecondsSinceEpoch;
        final String fileKey =
            "foodie-pos/msquarefdc-batch3/sit-naing-soe/$timestamp\_profile.jpg";

        final String accessKey = dotenv.env['DO_SPACE_ACCESS_KEY'] ?? '';

        final String secretKey = dotenv.env['DO_SPACE_SECRET_KEY'] ?? '';

        final file = File(_localImagePath!);
        final bytes = await file.readAsBytes();

        final now = DateTime.now().toUtc();
        final amzDate = DateFormat("yyyyMMdd'T'HHmmss'Z'").format(now);
        final dateStamp = DateFormat("yyyyMMdd").format(now);

        final endpoint =
            'https://$bucketName.$region.digitaloceanspaces.com/$fileKey';
        final uri = Uri.parse(endpoint);

        final headers = {
          'Host': '$bucketName.$region.digitaloceanspaces.com',
          'Content-Type': 'image/jpeg',
          'X-Amz-Content-Sha256': sha256.convert(bytes).toString(),
          'X-Amz-Date': amzDate,
          'X-Amz-Acl': 'public-read',
        };

        final credentialScope = '$dateStamp/$region/s3/aws4_request';
        final canonicalHeaders =
            'host:${headers['Host']}\nx-amz-acl:public-read\nx-amz-content-sha256:${headers['X-Amz-Content-Sha256']}\nx-amz-date:$amzDate\n';
        final signedHeaders = 'host;x-amz-acl;x-amz-content-sha256;x-amz-date';

        final String canonicalUri = '/${uri.pathSegments.join("/")}';
        final canonicalRequest =
            'PUT\n$canonicalUri\n\n$canonicalHeaders\n$signedHeaders\n${headers['X-Amz-Content-Sha256']}';

        final stringToSign =
            'AWS4-HMAC-SHA256\n$amzDate\n$credentialScope\n${sha256.convert(utf8.encode(canonicalRequest))}';

        final kDate = hmacSha256(utf8.encode('AWS4$secretKey'), dateStamp);
        final kRegion = hmacSha256(kDate, region);
        final kService = hmacSha256(kRegion, 's3');
        final kSigning = hmacSha256(kService, 'aws4_request');
        final signature = hexEncode(hmacSha256(kSigning, stringToSign));

        headers['Authorization'] =
            'AWS4-HMAC-SHA256 Credential=$accessKey/$credentialScope, SignedHeaders=$signedHeaders, Signature=$signature';

        final response = await http.put(uri, headers: headers, body: bytes);

        if (response.statusCode == 200) {
          final String downloadUrl =
              'https://msquarefdc.sgp1.cdn.digitaloceanspaces.com/$fileKey';
          if (kDebugMode) {
            print("✅ Image uploaded successfully: $downloadUrl");
          }
          // Firestore Update
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'image': downloadUrl});

          // Hive & Riverpod State Update
          final authBox = Hive.box('authBox');
          final cacheUserData = authBox.get('current_user');
          if (cacheUserData != null) {
            final updatedUserData = cacheUserData.copyWith(image: downloadUrl);
            await authBox.put('current_user', updatedUserData);
            ref.read(authProvider.notifier).updateUserState(updatedUserData);
          }
        } else {
          throw Exception(
            'DigitalOcean upload failed: ${response.statusCode}\n${response.body}',
          );
        }
      }

      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
        if (kDebugMode) {
          print("❌ Error during profile setup: $e");
        }
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider).value;
    final existingImageUrl = authState?.image ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: isLoading ? null : () => _saveAndContinue(isSkip: true),
            child: const Text(
              'Skip',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 40.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Upload Profile Picture',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Add a profile picture so your friends can easily recognize you.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 50),

                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 3,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 70,
                            backgroundColor: Colors.grey[100],
                            backgroundImage: _localImagePath != null
                                ? FileImage(File(_localImagePath!))
                                      as ImageProvider
                                : (existingImageUrl.isNotEmpty
                                      ? (existingImageUrl.startsWith('http')
                                            ? NetworkImage(existingImageUrl)
                                            : AssetImage(existingImageUrl)
                                                  as ImageProvider)
                                      : const AssetImage(
                                              'assets/images/profile.png',
                                            )
                                            as ImageProvider),
                          ),
                        ),
                        if (_localImagePath != null)
                          Positioned(
                            bottom: 0,
                            right: 4,
                            child: CircleAvatar(
                              backgroundColor: Colors.red,
                              radius: 20,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                onPressed: () =>
                                    setState(() => _localImagePath = null),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 50),

                    // 📸 Take Photo ခလုတ်
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.photo_camera),
                      label: const Text(
                        'Take a Photo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 🖼️ Choose From Gallery ခလုတ်
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue, width: 1.5),
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text(
                        'Choose from Gallery',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 🏁 Save & Continue Button (ပုံရွေးထားမှသာ ပေါ်လာမည်)
                    if (_localImagePath != null)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(220, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 2,
                          ),
                          onPressed: () => _saveAndContinue(isSkip: false),
                          child: const Text(
                            'Save & Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
