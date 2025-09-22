import 'package:flutter/material.dart';

class ShiftDetailScreen extends StatelessWidget {
  final Map<String, String> shift;

  const ShiftDetailScreen({super.key, required this.shift});

  Color getStatusColor(String? status) {
    switch (status) {
      case "Disetujui":
        return Colors.green;
      case "Ditolak":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData getStatusIcon(String? status) {
    switch (status) {
      case "Disetujui":
        return Icons.check_circle;
      case "Ditolak":
        return Icons.cancel;
      default:
        return Icons.hourglass_top;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = shift["status"];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Lembur & Piket"),
        centerTitle: true,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: getStatusColor(status).withOpacity(0.1),
                      child: Icon(
                        getStatusIcon(status),
                        color: getStatusColor(status),
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        shift["type"] ?? "-",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Detail Tiles
                _buildDetailTile("Tipe", shift["type"] ?? "-"),
                _buildDetailTile("Tanggal", shift["date"] ?? "-"),
                _buildDetailTile(
                    "Jam", "${shift["start"] ?? "-"} - ${shift["end"] ?? "-"}"),
                _buildDetailTile("Durasi", shift["duration"] ?? "-"),

                // Reason jika Ditolak
                if (status == "Ditolak" && (shift["reason"] ?? "").isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Text(
                      "Reason: ${shift["reason"]}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),

                // Status di bawah
                if (status != null)
                  _buildStatusTile("Status", status, getStatusColor(status)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailTile(String title, String value) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 15, color: Colors.black87),
      ),
    );
  }

  Widget _buildStatusTile(String title, String value, Color color) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      subtitle: Row(
        children: [
          Icon(Icons.circle, size: 12, color: color),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
