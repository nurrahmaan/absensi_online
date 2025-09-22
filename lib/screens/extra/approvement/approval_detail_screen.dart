import 'package:flutter/material.dart';
import '../../models/approval.dart';

class ApprovalDetailScreen extends StatelessWidget {
  final Approval approval;

  const ApprovalDetailScreen({super.key, required this.approval});

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
        return Colors.black;
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
    if (text == null || text.isEmpty) return "-";
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Widget _buildDetailRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? "-",
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(approval.status);
    final statusIcon = _getStatusIcon(approval.status);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Persetujuan"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Status badge di atas
                CircleAvatar(
                  radius: 32,
                  backgroundColor: statusColor.withOpacity(0.15),
                  child: Icon(statusIcon, size: 36, color: statusColor),
                ),
                const SizedBox(height: 12),
                Text(
                  _toTitleCase(approval.status),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 24),

                // Category & Subcategory
                _buildDetailRow("Kategori", _toTitleCase(approval.category)),
                _buildDetailRow(
                    "Sub Kategori", _toTitleCase(approval.subcategory)),
                _buildDetailRow("Keterangan", approval.keterangan),
                const Divider(height: 32),

                // Tanggal
                _buildDetailRow("Tanggal Mulai", approval.startdate),
                _buildDetailRow("Tanggal Selesai", approval.enddate),
                _buildDetailRow("Tanggal Pengajuan", approval.reqdate),
                const Divider(height: 32),

                // Alasan Ditolak, Jadwal, Absen (sesuai category)
                if (approval.reason != null && approval.reason!.isNotEmpty)
                  _buildDetailRow("Alasan Ditolak", approval.reason),
                if (approval.category?.toLowerCase() == "dispensasi") ...[
                  if (approval.jadwal != null && approval.jadwal!.isNotEmpty)
                    _buildDetailRow("Jadwal", approval.jadwal),
                  if (approval.absen != null && approval.absen!.isNotEmpty)
                    _buildDetailRow("Absen", approval.absen),
                ],

                // Durasi di paling bawah
                _buildDetailRow("Durasi", approval.durasi),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
