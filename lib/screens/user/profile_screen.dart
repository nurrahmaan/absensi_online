import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/login_provider.dart';
import '../../widgets/notifications/top_notification.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _logout(BuildContext context) async {
    // 1️⃣ Hapus token via LoginProvider
    await context.read<LoginProvider>().logout();

    // 2️⃣ Redirect ke LoginScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );

    // 3️⃣ Tampilkan notifikasi sukses
    showTopNotification(context, 'Berhasil logout');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5E35B1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 100, color: Colors.white70),
            const SizedBox(height: 16),
            const Text(
              'Rahman',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'rahman@example.com',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
