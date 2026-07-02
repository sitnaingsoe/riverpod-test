import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_test/features/auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/edit-profile');
            },
            icon: const Icon(
              Icons.edit_note_rounded,
              color: Colors.black87,
              size: 26,
            ),
          ),
        ],
      ),
      body: authAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(strokeWidth: 3)),
        error: (err, stack) => Center(
          child: Text(
            'Error loading profile: $err',
            style: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        data: (user) {
          if (user == null) {
            return const SizedBox.shrink();
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 👤 User Main Header Card ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey.shade100,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 36,
                            backgroundColor: Colors.grey.shade100,
                            backgroundImage: user.image.isNotEmpty
                                ? (user.image.startsWith('http')
                                      ? NetworkImage(user.image)
                                            as ImageProvider
                                      : AssetImage(user.image) as ImageProvider)
                                : const AssetImage('assets/images/profile.png'),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.username,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${user.firstName} ${user.lastName}",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- 🎛️ Grid Menu Items ---
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.4,
                    children: [
                      buildGridItem(
                        Icons.favorite_rounded,
                        "Favorite",
                        Colors.redAccent.shade200,
                        () => Navigator.pushNamed(context, '/favorite'),
                      ),
                      buildGridItem(
                        Icons.shopping_bag_rounded,
                        "Orders",
                        Colors.blueAccent.shade200,
                        () => Navigator.pushNamed(context, "/history-order"),
                      ),
                      buildGridItem(
                        Icons.account_balance_wallet_rounded,
                        "Payment",
                        Colors.purpleAccent.shade400,
                        () => Navigator.pushNamed(context, "/payment"),
                      ),
                      buildGridItem(
                        Icons.location_on_rounded,
                        "Address",
                        Colors.orangeAccent.shade200,
                        () => Navigator.pushNamed(context, "/address"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- ℹ️ Information Card ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Account Details",
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Divider(color: Colors.grey.shade100, thickness: 1.2),
                        const SizedBox(height: 8),
                        buildInfoRow(Icons.email_outlined, "Email", user.email),
                        buildInfoRow(
                          Icons.person_outline_rounded,
                          "Gender",
                          user.gender,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- ⚙️ General Settings Card ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey.shade50,
                            child: Icon(
                              Icons.help_outline_rounded,
                              color: Colors.blueGrey.shade600,
                              size: 22,
                            ),
                          ),
                          title: const Text(
                            "Help & Support",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: Colors.grey.shade400,
                          ),
                          onTap: () {},
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Divider(
                            color: Colors.grey.shade50,
                            thickness: 1,
                          ),
                        ),
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey.shade50,
                            child: Icon(
                              Icons.privacy_tip_outlined,
                              color: Colors.blueGrey.shade600,
                              size: 22,
                            ),
                          ),
                          title: const Text(
                            "Privacy & Policy",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: Colors.grey.shade400,
                          ),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- 🚪 Logout Button ---
                  SizedBox(
                    height: 54,
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: BorderSide(
                          color: Colors.redAccent.shade100,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded, size: 20),
                      label: const Text("Logout"),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: const Row(
                                children: [
                                  Icon(
                                    Icons.logout_rounded,
                                    color: Colors.redAccent,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Logout',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              content: const Text(
                                'Are you sure you want to logout from your account?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    ref.read(authProvider.notifier).logout();
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/login',
                                    );
                                  },
                                  child: const Text('Logout'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildGridItem(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey.shade400),
          const SizedBox(width: 14),
          Text(
            "$label:",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
