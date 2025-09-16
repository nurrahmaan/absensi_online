import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/absensi/history_provider.dart';
import '../../services/api_service.dart';

class HistoryScreen extends StatelessWidget {
  final String token;
  const HistoryScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          HistoryProvider(api: ApiService(), token: token)..fetchHistory(),
      child: Consumer<HistoryProvider>(
        builder: (context, historyProvider, _) {
          return Scaffold(
            appBar: AppBar(title: const Text("Riwayat Absensi")),
            body: Column(
              children: [
                // ===== Filter Bulan & Tahun =====
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: historyProvider.selectedMonth,
                          items: List.generate(12, (index) => index + 1)
                              .map((m) => DropdownMenuItem(
                                    value: m,
                                    child: Text(DateFormat.MMM()
                                        .format(DateTime(0, m))),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) historyProvider.setMonth(val);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: historyProvider.selectedYear,
                          items: List.generate(
                                  5, (index) => DateTime.now().year - index)
                              .map((y) => DropdownMenuItem(
                                  value: y, child: Text(y.toString())))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) historyProvider.setYear(val);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // ===== List History =====
                Expanded(
                  child: historyProvider.loading
                      ? const Center(child: CircularProgressIndicator())
                      : historyProvider.history.isEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.history,
                                    size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                const Text(
                                  "Belum ada data absensi bulan ini",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: historyProvider.history.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 4),
                              itemBuilder: (context, index) {
                                final item = historyProvider.history[index];
                                return Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    title: Text(
                                      item['tgl_absen'] ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Masuk: ${item['absen1']}"),
                                        Text("Pulang: ${item['absen2']}"),
                                      ],
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(item['status']),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        item['status'] ?? '',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case "On-time":
        return Colors.green;
      case "Belum Absen":
        return Colors.orange;
      case "Terlambat":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
