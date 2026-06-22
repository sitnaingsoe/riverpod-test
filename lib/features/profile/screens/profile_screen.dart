import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_test/features/auth/screens/login.dart';
import 'package:riverpod_test/features/profile/providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (err, stack) =>
            Center(child: Text('Error loading profile: $err')),

        data: (user) {
          if (user == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            });
            return const SizedBox.shrink();
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 120,
                    padding: const EdgeInsets.only(top: 30, left: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(color: Colors.grey, blurRadius: 3),
                      ],
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: user.image.isNotEmpty
                              ? NetworkImage(user.image)
                              : const AssetImage(
                                      'assets/images/default-image.jpg',
                                    )
                                    as ImageProvider,
                        ),
                        const SizedBox(width: 20),
                        Text(
                          user.username,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: const [
                        BoxShadow(color: Colors.grey, blurRadius: 1),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Your Information".toUpperCase(),
                          style: const TextStyle(
                            color: Color.fromARGB(255, 45, 44, 44),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "Email : ${user.email}",
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "First Name : ${user.firstName}",
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "Last Name : ${user.lastName}",
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "Gender : ${user.gender}",
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // --- 🎛️ Grid Menu Items ---
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.5,
                    children: [
                      buildGridItem(
                        Icons.favorite,
                        "Favorite",
                        Colors.red,
                        () => context.push("/favorites"),
                      ),
                      buildGridItem(
                        Icons.shopping_cart,
                        "Orders",
                        Colors.blue,
                        () => context.push("/orders"),
                      ),
                      buildGridItem(
                        Icons.payment,
                        "Payment",
                        Colors.green,
                        () => Navigator.pushNamed(context, "/payment"),
                      ),
                      buildGridItem(
                        Icons.location_pin,
                        "Address",
                        Colors.orange,
                        () => Navigator.pushNamed(context, "/address"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // --- ⚙️ General Settings ---
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: const [
                        BoxShadow(color: Colors.grey, blurRadius: 1),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "General".toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: const [
                            Icon(Icons.help, color: Colors.grey),
                            SizedBox(width: 15),
                            Text("Help", style: TextStyle(color: Colors.black)),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: const [
                            Icon(Icons.security, color: Colors.grey),
                            SizedBox(width: 15),
                            Text(
                              "Privacy & Policy",
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  // --- 🚪 Logout Button ---
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                      ), // 💡 အရောင် ထည့်ပေးထားပါတယ်
                      onPressed: () {
                        // 🔥 Notifier ထဲက logout ကို လှမ်းခေါ်ခြင်း
                        ref.read(profileProvider.notifier).logout();
                      },
                      child: const Text(
                        "Logout",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper Widget ပုံစံထုတ်ရန် (လက်ရှိ သင့်ကုဒ်ထဲကအတိုင်း)
  Widget buildGridItem(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 5),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
