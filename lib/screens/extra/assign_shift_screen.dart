import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/user_provider.dart';

class AssignShiftScreen extends StatelessWidget {
  const AssignShiftScreen({super.key, required String token});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final jabatan = userProvider.userProfile['jabatan'] ?? '';

    // Jika bukan Koordinator, tampilkan pesan atau navigasi kembali
    if (jabatan != 'Koordinator') {
      return Scaffold(
        appBar: AppBar(title: const Text("Assign Shift")),
        body: const Center(
          child: Text("Anda tidak memiliki akses untuk menu ini."),
        ),
      );
    }

    // Jika Koordinator, tampilkan menu Assign Shift
    return Scaffold(
      appBar: AppBar(title: const Text("Assign Shift")),
      body: const Center(
        child: Text("Halaman Assign Shift (hanya untuk Koordinator)"),
      ),
    );
  }
}
