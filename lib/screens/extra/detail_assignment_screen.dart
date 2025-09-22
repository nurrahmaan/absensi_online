import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailAssignmentScreen extends StatelessWidget {
  final Map<String, dynamic> assignment;

  const DetailAssignmentScreen({super.key, required this.assignment});

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

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'assign':
        return Icons.assignment_outlined;
      case 'ongoing':
        return Icons.play_circle_fill;
      case 'completed':
        return Icons.check_circle;
      case 'failed':
        return Icons.error_outline;
      case 'canceled':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
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

  Widget _buildRow(String label, String value) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 130,
                child: Text(
                  "$label:",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Text(value),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final nama = assignment['nama'] ?? '-';
    final kategori = (assignment['kategori'] ?? '-').toString().toUpperCase();
    final dihari = assignment['dihari'] ?? '-';
    final tglExtra = _formatDate(assignment['tgl_extra'] ?? '');
    final masuk = _formatTime(assignment['jadwal_masuk']);
    final pulang = _formatTime(assignment['jadwal_pulang']);
    final uraian = assignment['uraian'] ?? '-';
    final status = (assignment['status'] ?? 'assign').toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Assignment"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status "Profile style"
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: _statusColor(status).withOpacity(0.15),
                    child: Icon(
                      _statusIcon(status),
                      size: 36,
                      color: _statusColor(status),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _statusColor(status),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Nama + Task + Dihari
            Text(
              nama,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text("Task: $kategori · ${dihari.toUpperCase()}"),
            const SizedBox(height: 20),

            // Detail rows
            _buildRow("Tanggal", tglExtra),
            _buildRow("Jam", "$masuk - $pulang"),
            _buildRow("Uraian", uraian),
            _buildRow("Tanggal Assign", tglExtra),

            const SizedBox(height: 24),

            // Button
            if (status.toLowerCase() == 'assign')
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // TODO: Cancel assignment action
                    },
                    child: const Text(
                      "Cancel Assignment",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
