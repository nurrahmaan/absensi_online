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
            backgroundColor: Colors.grey.shade100,
            body: Column(
              children: [
                // ===== Header Judul + Filter =====
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade600,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Riwayat Absensi",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButton<int>(
                                isExpanded: true,
                                value: historyProvider.selectedMonth,
                                underline: const SizedBox(),
                                items: List.generate(12, (index) => index + 1)
                                    .map((m) => DropdownMenuItem(
                                          value: m,
                                          child: Text(DateFormat.MMMM()
                                              .format(DateTime(0, m))),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    historyProvider.setMonth(val);
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButton<int>(
                                isExpanded: true,
                                value: historyProvider.selectedYear,
                                underline: const SizedBox(),
                                items: List.generate(2,
                                        (index) => DateTime.now().year - index)
                                    .map((y) => DropdownMenuItem(
                                          value: y,
                                          child: Text(y.toString()),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    historyProvider.setYear(val);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ===== List History =====
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await historyProvider.fetchHistory();
                    },
                    child: historyProvider.loading
                        ? const Center(child: CircularProgressIndicator())
                        : historyProvider.history.isEmpty
                            ? ListView(
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.6,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.history,
                                            size: 64,
                                            color: Colors.grey.shade400),
                                        const SizedBox(height: 16),
                                        const Text(
                                          "Belum ada data absensi bulan ini",
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                itemCount: historyProvider.history.length,
                                itemBuilder: (context, index) {
                                  final item = historyProvider.history[index];
                                  return Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(16),
                                      title: Text(
                                        item['tgl_absen'] ?? '',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.indigo.shade700,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Masuk: ${item['absen1']}",
                                              style: TextStyle(
                                                  color: Colors.grey.shade700)),
                                          Text("Pulang: ${item['absen2']}",
                                              style: TextStyle(
                                                  color: Colors.grey.shade700)),
                                        ],
                                      ),
                                      trailing: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color:
                                              _getStatusColor(item['status']),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          item['status'] ?? '',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
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
        return Colors.green.shade600;
      case "Belum Absen":
        return Colors.orange.shade600;
      case "Terlambat":
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
}
