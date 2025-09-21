// lib/screens/user/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../providers/user/profile_provider.dart';
import '../auth/login_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String token;
  const ProfileScreen({required this.token, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          ProfileProvider(api: ApiService(), token: token)..fetchProfile(),
      child: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final profile = provider.profile;
          if (profile.isEmpty) {
            return const Scaffold(
              body: Center(child: Text('Data profil tidak ditemukan')),
            );
          }

          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  ProfileHeader(
                    nama: profile['nama'] ?? '-',
                    username: profile['username'] ?? '-',
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  ProfileDetails(
                    kantor: profile['kantor'] ?? '-',
                    department: profile['department'] ?? '-',
                    lokasi: profile['lokasi_absen'] ?? '-',
                  ),
                  const Divider(),
                  Expanded(
                    child: ProfileMenu(
                      token: token,
                      onLogout: () => _showLogoutDialog(context),
                    ),
                  ),

                  // === Info Versi Aplikasi (paling bawah) ===
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Versi 1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('token');
              Navigator.of(ctx).pop();

              // showTopNotification(
              //   context,
              //   "Berhasil logout",
              //   type: NotificationType.success,
              // );

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

/// ==== Widgets Kecil ====

class ProfileHeader extends StatelessWidget {
  final String nama;
  final String username;

  const ProfileHeader({super.key, required this.nama, required this.username});

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return (parts[0][0] + parts[1][0]).toUpperCase();
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.deepPurple.shade100,
          child: Text(
            _getInitials(nama),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(nama,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(username, style: TextStyle(color: Colors.grey.shade600)),
      ],
    );
  }
}

class ProfileDetails extends StatelessWidget {
  final String kantor;
  final String department;
  final String lokasi;

  const ProfileDetails({
    super.key,
    required this.kantor,
    required this.department,
    required this.lokasi,
  });

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          _buildDetailRow('Kantor', kantor),
          _buildDetailRow('Departemen', department),
          _buildDetailRow('Lokasi Absen', lokasi),
        ],
      ),
    );
  }
}

class ProfileMenu extends StatelessWidget {
  final String token;
  final VoidCallback onLogout;

  const ProfileMenu({super.key, required this.token, required this.onLogout});

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.deepPurple),
          title: Text(title),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildMenuItem(Icons.lock_outline, 'Ganti Password', () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangePasswordScreen(token: token),
            ),
          );
        }),
        _buildMenuItem(Icons.logout, 'Logout', onLogout),
      ],
    );
  }
}
