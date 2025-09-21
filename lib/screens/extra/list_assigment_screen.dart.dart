import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../extra/add_assigment_screen.dart';
import 'package:intl/intl.dart';

class ListAssignmentScreen extends StatefulWidget {
  final String token;
  const ListAssignmentScreen({required this.token, super.key});

  @override
  State<ListAssignmentScreen> createState() => _ListAssignmentScreenState();
}

class _ListAssignmentScreenState extends State<ListAssignmentScreen> {
  final ApiService _apiService = ApiService();
  bool isLoading = true;
  List<Map<String, dynamic>> assignments = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _apiService.getAssignments(widget.token);

      if (response['success'] == true && response['data'] != null) {
        final List data = response['data'];
        setState(() {
          assignments = List<Map<String, dynamic>>.from(data);
        });
      } else {
        setState(() {
          errorMessage = response['message'] ?? 'Gagal memuat assignments';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _cancelAssignment(Map<String, dynamic> assignment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Batalkan Assignment"),
        content: Text(
            "Yakin ingin membatalkan assignment untuk ${assignment['nama']}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Tidak"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Ya, Batalkan"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // Asumsi ada endpoint cancelAssignment(id, token)
      final res = await _apiService.cancelAssignment(
        assignment['id'], // pastikan field ID ada di response
        widget.token,
      );

      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Assignment berhasil dibatalkan")),
        );
        _loadAssignments();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Gagal: ${res['message'] ?? 'Tidak diketahui'}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'assign':
        return Colors.orange;
      case 'done':
        return Colors.green;
      case 'cancel':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return isoDate;
    }
  }

  String _formatTime(String? isoTime) {
    if (isoTime == null) return '-';
    try {
      final dt = DateTime.parse(isoTime).toLocal();
      return DateFormat('HH:mm').format(dt);
    } catch (_) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Assignment"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final added = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddAssignmentScreen(token: widget.token),
                ),
              );
              if (added == true) _loadAssignments();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : ListView.separated(
                  itemCount: assignments.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = assignments[index];
                    final nama = item['nama'] ?? '-';
                    final tglExtra = _formatDate(item['tgl_extra'] ?? '');
                    final kategori = item['kategori'] ?? '-';
                    final dihari = item['dihari'] ?? '-';
                    final masuk = _formatTime(item['jadwal_masuk']);
                    final pulang = _formatTime(item['jadwal_pulang']);
                    final uraian = item['uraian'] ?? '-';
                    final status = item['status'] ?? 'assign';
                    final assignBy = item['assign_by'] ?? '-';

                    return ListTile(
                      title: Text("$nama ($kategori)"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("$tglExtra | $dihari"),
                          Text("Jam: $masuk - $pulang"),
                          Text("Uraian: $uraian"),
                          Text("Assign by: $assignBy"),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            decoration: BoxDecoration(
                              color: _statusColor(status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (status.toLowerCase() == 'assign') ...[
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              tooltip: "Batalkan Assignment",
                              onPressed: () => _cancelAssignment(item),
                            ),
                          ]
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
