import 'package:absensi_online/screens/extra/list_assigment_screen.dart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/user_provider.dart';
import 'shift_management_screen.dart';
import 'e_library_screen.dart';
import 'approval_status_screen.dart';

class MoreScreen extends StatelessWidget {
  final String token;
  const MoreScreen({required this.token, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Menu Lainnya")),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          // Kalau masih loading
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Kalau ada error dari API
          if (userProvider.errorMessage != null &&
              userProvider.errorMessage!.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Error: ${userProvider.errorMessage}",
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // Ambil role dari profile
          final isKoordinator = userProvider.jabatan == 'Koordinator';

          return ListView(
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
              if (isKoordinator) ...[
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.assignment_sharp),
                  title: const Text("Assign Lembur / Piket"),
                  subtitle: const Text("Jadwalkan Lembur / Piket tim"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ListAssignmentScreen(token: token),
                      ),
                    );
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
