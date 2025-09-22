import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/user_provider.dart';
import '../../services/api_service.dart';
import '../extra/add_assigment_screen.dart';
import 'detail_assignment_screen.dart';
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
  List<Map<String, dynamic>> filteredAssignments = [];
  String? errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAssignments();
    _searchController.addListener(_applySearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          filteredAssignments = assignments;
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

  void _applySearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredAssignments = assignments.where((item) {
        final nama = (item['nama'] ?? '').toString().toLowerCase();
        final kategori = (item['kategori'] ?? '').toString().toLowerCase();
        return nama.contains(query) || kategori.contains(query);
      }).toList();
    });
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Ya, Batalkan",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final res = await _apiService.cancelAssignment(
        assignment['id'],
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
      case 'ongoing':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'failed':
        return Colors.redAccent;
      case 'canceled':
        return Colors.grey;
      default:
        return Colors.black45;
    }
  }

  Color _dihariColor(String dihari) {
    switch (dihari.toLowerCase()) {
      case 'dihari libur':
        return Colors.redAccent;
      case 'dihari kerja':
        return Colors.blueAccent;
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
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Cari berdasarkan nama atau task...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                    ? Center(child: Text(errorMessage!))
                    : RefreshIndicator(
                        onRefresh: _loadAssignments,
                        child: ListView.separated(
                          itemCount: filteredAssignments.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final item = filteredAssignments[index];
                            final nama = item['nama'] ?? '-';
                            final kategori = (item['kategori'] ?? '-')
                                .toString()
                                .toUpperCase();
                            final tglExtra =
                                _formatDate(item['tgl_extra'] ?? '');
                            final dihari = item['dihari'] ?? '-';
                            final masuk = _formatTime(item['jadwal_masuk']);
                            final pulang = _formatTime(item['jadwal_pulang']);
                            final status =
                                (item['status'] ?? 'assign').toString();

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DetailAssignmentScreen(
                                      assignment: item,
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                child: Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Kiri
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  nama,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    Text("Task: $kategori"),
                                                    const Text(" · "),
                                                    Text(
                                                      dihari.toUpperCase(),
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: _dihariColor(
                                                            dihari),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text("Tanggal: $tglExtra"),
                                                const SizedBox(height: 2),
                                                Text("Jam: $masuk - $pulang"),
                                              ],
                                            ),
                                          ),
                                          // Kanan (status badge)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6, horizontal: 12),
                                            decoration: BoxDecoration(
                                              color: _statusColor(status),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              status.toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (status.toLowerCase() == 'assign') ...[
                                        const SizedBox(height: 14),
                                        Center(
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              onPressed: () =>
                                                  _cancelAssignment(item),
                                              child: const Text(
                                                "Cancel Assignment",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]
                                    ],
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Ambil userProfile dari UserProvider
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);

          final added = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddAssignmentScreen(
                token: widget.token,
                // ✅ diisi dari provider
              ),
            ),
          );

          if (added == true) _loadAssignments();
        },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          "Tambah Assignment",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
