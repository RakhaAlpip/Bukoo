import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../providers/auth_provider.dart';
import 'history_page.dart';
import 'favorite_list_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    const Color primaryBlue = Color(0xFF0D47A1);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profil Saya", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: primaryBlue,
                    child: Text(
                      (user?.displayName != null && user!.displayName!.isNotEmpty)
                          ? user.displayName![0].toUpperCase() 
                          : "U", 
                      style: const TextStyle(
                        fontSize: 40, 
                        color: Colors.white, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.displayName ?? "Nama Pengguna",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryBlue),
                  ),
                  Text(
                    user?.email ?? "email@example.com",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            _buildMenuTile(
              icon: Icons.bookmark_rounded,
              title: "Buku Favorit Saya",
              onTap: () => Get.to(() => const FavoriteListPage()),
            ),
            _buildMenuTile(
              icon: Icons.history_rounded,
              title: "Riwayat Penyewaan",
              onTap: () => Get.to(() => const HistoryPage()),
            ),
            _buildMenuTile(
              icon: Icons.security_rounded,
              title: "Ubah Password",
              onTap: () => Get.snackbar("Info", "Fitur ini akan segera hadir"),
            ),
            _buildMenuTile(
              icon: Icons.help_outline_rounded,
              title: "Bantuan & Dukungan",
              onTap: () {},
            ),
            const SizedBox(height: 20),
            const Divider(indent: 20, endIndent: 20),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: () => _showLogoutDialog(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Keluar dari Akun", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
            Text("Bukoo App v1.0.0", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: const Color(0xFF0D47A1)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right_rounded),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    Get.defaultDialog(
      title: "Konfirmasi",
      middleText: "Apakah kamu yakin ingin keluar?",
      textConfirm: "Ya, Keluar",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF0D47A1),
      onConfirm: () {
        ref.read(authProvider).signOut();
        Get.back();
      },
    );
  }
}