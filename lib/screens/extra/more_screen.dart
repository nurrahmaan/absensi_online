import 'package:flutter/material.dart';
import 'shift_management_screen.dart';
import 'e_library_screen.dart';
import '../../screens/extra/approval_status_screen.dart'; // ✅ tambahkan ini

class MoreScreen extends StatelessWidget {
  final String token;
  const MoreScreen({required this.token, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Menu Lainnya")),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.assignment_turned_in),
            title: const Text("Status Persetujuan"),
            subtitle: const Text("Izin, Cuti, dan Dispensasi"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ApprovalStatusScreen(token: token),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text("Lembur & Shift Management"),
            subtitle: const Text("Kelola jadwal shift dan lembur"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ShiftManagementScreen(token: token),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: const Text("E-Library"),
            subtitle: const Text("Akses dokumen dan referensi"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ELibraryScreen(token: token),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
