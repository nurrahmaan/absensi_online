import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AbsensiScreen extends StatefulWidget {
  final String token;
  const AbsensiScreen({required this.token, super.key});

  @override
  State<AbsensiScreen> createState() => _AbsensiScreenState();
}

class _AbsensiScreenState extends State<AbsensiScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String _status = "Belum Absen";
  String? _lastTime;

  Future<void> _checkIn() async {
    setState(() => _isLoading = true);

    try {
      final result = await _apiService.absen(widget.token, "in");
      if (result["success"] == true) {
        setState(() {
          _status = "Sudah Check In";
          _lastTime = result["time"];
        });
      } else {
        _showError(result["message"] ?? "Gagal check in");
      }
    } catch (e) {
      _showError("Terjadi kesalahan: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkOut() async {
    setState(() => _isLoading = true);

    try {
      final result = await _apiService.absen(widget.token, "out");
      if (result["success"] == true) {
        setState(() {
          _status = "Sudah Check Out";
          _lastTime = result["time"];
        });
      } else {
        _showError(result["message"] ?? "Gagal check out");
      }
    } catch (e) {
      _showError("Terjadi kesalahan: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // biar tidak kena notch
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading:
                    const Icon(Icons.access_time, color: Colors.deepPurple),
                title: Text(
                  _status,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: _lastTime != null
                    ? Text("Terakhir: $_lastTime")
                    : const Text("Belum ada data"),
              ),
            ),
            const SizedBox(height: 32),

            // Tombol
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _checkIn,
                  icon: const Icon(Icons.login),
                  label: const Text("Check In"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _checkOut,
                  icon: const Icon(Icons.logout),
                  label: const Text("Check Out"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                  ),
                ),
              ],
            ),
            if (_isLoading) const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
              ),
          ],
        ),
      ),
    );
  }
}
