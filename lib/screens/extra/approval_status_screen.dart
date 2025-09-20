import 'package:absensi_online/providers/extra/approval_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'approval_detail_screen.dart';

class ApprovalStatusScreen extends StatefulWidget {
  final String token;
  const ApprovalStatusScreen({super.key, required this.token});

  @override
  State<ApprovalStatusScreen> createState() => _ApprovalStatusScreenState();
}

class _ApprovalStatusScreenState extends State<ApprovalStatusScreen> {
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ApprovalProvider>(context, listen: false)
          .fetchApprovals(widget.token);
    });
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case "active":
        return Colors.indigo;
      case "done":
        return Colors.green;
      case "declined":
      case "rejected":
        return Colors.red;
      case "evaluation":
        return Colors.orange;
      case "requested":
      case "awaiting":
        return Colors.black87;
      case "approved":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case "active":
        return Icons.play_arrow;
      case "done":
        return Icons.check_circle;
      case "declined":
      case "rejected":
        return Icons.close_rounded;
      case "evaluation":
        return Icons.hourglass_bottom;
      case "requested":
      case "awaiting":
        return Icons.near_me;
      case "approved":
        return Icons.check;
      default:
        return Icons.help_outline;
    }
  }

  String _toTitleCase(String? text) {
    if (text == null) return "-";
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Status Persetujuan"),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Cari kategori / subkategori / status...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
        ),
      ),
      body: Consumer<ApprovalProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Text(
                provider.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final approvals = provider.approvals.where((a) {
            final query = _searchQuery.toLowerCase();
            return a.category?.toLowerCase().contains(query) == true ||
                a.subcategory?.toLowerCase().contains(query) == true ||
                a.status?.toLowerCase().contains(query) == true;
          }).toList();

          if (approvals.isEmpty) {
            return const Center(child: Text("Tidak ada data persetujuan."));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.fetchApprovals(widget.token);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: approvals.length,
              itemBuilder: (context, index) {
                final approval = approvals[index];
                final statusColor = _getStatusColor(approval.status);
                final statusIcon = _getStatusIcon(approval.status);

                return Card(
                  elevation: 4,
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
                          builder: (_) =>
                              ApprovalDetailScreen(approval: approval),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: category + status chip
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _toTitleCase(approval.category),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      statusIcon,
                                      size: 16,
                                      color: statusColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      approval.status ?? "-",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: statusColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _toTitleCase(approval.subcategory),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Tanggal: ${approval.startdate ?? '-'} s/d ${approval.enddate ?? '-'}",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
