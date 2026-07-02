import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DigitalOceanStorageService {
  static List<int> _hmacSha256(List<int> key, String data) {
    return Hmac(sha256, key).convert(utf8.encode(data)).bytes;
  }

  static String _hexEncode(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static Future<String> uploadProfileImage(String localImagePath) async {
    final String region = "sgp1";
    final String bucketName = "msquarefdc";
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    final String fileKey =
        "foodie-pos/msquarefdc-batch3/sit-naing-soe/${timestamp}_profile.jpg";

    final String accessKey = 'DO00Z6FFVCRMLJ9DTHY4';
    final String secretKey = 'ZOF2X6sEyK5ARE/VW86A7tHmMer/TooraKMRlxOvRyY';

    if (accessKey.isEmpty || secretKey.isEmpty) {
      throw Exception('❌ Error: DigitalOcean Keys are missing in .env file');
    }

    final file = File(localImagePath);
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

    final kDate = _hmacSha256(utf8.encode('AWS4$secretKey'), dateStamp);
    final kRegion = _hmacSha256(kDate, region);
    final kService = _hmacSha256(kRegion, 's3');
    final kSigning = _hmacSha256(kService, 'aws4_request');
    final signature = _hexEncode(_hmacSha256(kSigning, stringToSign));

    headers['Authorization'] =
        'AWS4-HMAC-SHA256 Credential=$accessKey/$credentialScope, SignedHeaders=$signedHeaders, Signature=$signature';

    final response = await http.put(uri, headers: headers, body: bytes);

    if (response.statusCode == 200) {
      return 'https://msquarefdc.sgp1.cdn.digitaloceanspaces.com/$fileKey';
    } else {
      throw Exception(
        'DigitalOcean upload failed: ${response.statusCode}\n${response.body}',
      );
    }
  }
}
