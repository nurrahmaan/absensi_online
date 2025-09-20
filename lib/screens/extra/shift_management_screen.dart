import 'package:flutter/material.dart';
import 'shift_detail_screen.dart';
import 'absen_pulang_shift_malam_screen.dart'; // Halaman baru

class ShiftManagementScreen extends StatelessWidget {
  final String token;
  const ShiftManagementScreen({required this.token, super.key});

  final List<Map<String, String>> lemburPiket = const [
    {"date": "2025-09-20", "start": "17:00", "end": "20:00", "type": "Lembur"},
    {"date": "2025-09-21", "start": "18:00", "end": "21:00", "type": "Lembur"},
    {"date": "2025-09-19", "start": "08:00", "end": "16:00", "type": "Piket"},
  ];

  IconData _getShiftIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'lembur':
        return Icons.work_outline;
      case 'piket':
        return Icons.schedule;
      default:
        return Icons.nightlight_round;
    }
  }

  Widget _buildLemburPiketList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: lemburPiket.length,
      itemBuilder: (context, index) {
        final item = lemburPiket[index];
        final icon = _getShiftIcon(item['type']);
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ShiftDetailScreen(shift: item),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.blueAccent.withOpacity(0.1),
                    child: Icon(icon, size: 28, color: Colors.blueAccent),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item['type'] != null)
                          Text(
                            item['type']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          "${item['date']}  ${item['start'] ?? '-'} - ${item['end'] ?? '-'}",
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Lembur & Shift Management"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Lembur & Piket"),
              Tab(text: "Absen Pulang Shift Malam"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Lembur & Piket
            _buildLemburPiketList(context),

            // Tab 2: Absen Pulang Shift Malam → panggil halaman sendiri
            AbsenPulangShiftMalamScreen(token: token),
          ],
        ),
      ),
    );
  }
}
