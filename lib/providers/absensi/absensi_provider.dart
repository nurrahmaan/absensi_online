import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/shared_prefs_helper.dart';

class AbsensiProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final List<Map<String, dynamic>> _offlineAbsenList = [];

  bool _isLoading = false;
  String? _message;
  List<Map<String, dynamic>> _lastFiveDays = [];
  Map<String, dynamic>? _jadwalToday;
  Map<String, dynamic>? _monthlySummary;
  List<Map<String, dynamic>> _lokasiKantor = [];

  bool get isLoading => _isLoading;
  String? get message => _message;
  List<Map<String, dynamic>> get lastFiveDays => _lastFiveDays;
  Map<String, dynamic>? get jadwalToday => _jadwalToday;
  Map<String, dynamic>? get monthlySummary => _monthlySummary;
  List<Map<String, dynamic>> get lokasiKantor => _lokasiKantor;

  // ================== ABSENSI ==================
  Future<void> absen(BuildContext context, String type,
      {required bool hasInternet, required bool hasServer}) async {
    final token = await SharedPrefsHelper.getToken();

    if (token == null) {
      _message = "Token tidak tersedia";
      notifyListeners();
      return;
    }

    if (hasInternet && hasServer) {
      _isLoading = true;
      notifyListeners();

      final result = await _apiService.absenMasuk(token, type);
      _isLoading = false;

      if (result["status"] == "success") {
        _message = result["message"] ?? "Absen berhasil";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_message!), backgroundColor: Colors.green),
        );
        // Refresh data
        await getLastFiveDays();
        await getJadwalToday();
      } else {
        _message = result["message"] ?? "Absen gagal";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_message!), backgroundColor: Colors.red),
        );
      }
    } else {
      // === Offline Mode ===
      final now = DateTime.now();
      _offlineAbsenList.add({
        "type": type,
        "timestamp": now.toIso8601String(),
      });
      _message = "Absen offline tersimpan";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_message!), backgroundColor: Colors.orange),
      );
    }

    notifyListeners();
  }

  // Sync Offline Absen
  Future<void> syncOfflineAbsen(
      {required bool hasInternet, required bool hasServer}) async {
    if (_offlineAbsenList.isEmpty) return;

    final token = await SharedPrefsHelper.getToken();
    if (token == null) return;

    if (hasInternet && hasServer) {
      for (var absen in List<Map<String, dynamic>>.from(_offlineAbsenList)) {
        final result = await _apiService.absenMasuk(token, absen["type"]);
        if (result["status"] == "success") {
          _offlineAbsenList.remove(absen);
        }
      }
      notifyListeners();
    }
  }

  // ================== DATA ABSENSI ==================
  Future<void> getJadwalToday() async {
    final token = await SharedPrefsHelper.getToken();
    if (token == null) return;

    _jadwalToday = await _apiService.getJadwalToday(token);
    notifyListeners();
  }

  Future<void> getMonthlySummary() async {
    final token = await SharedPrefsHelper.getToken();
    if (token == null) return;

    _monthlySummary = await _apiService.getMonthlySummary(token);
    notifyListeners();
  }

  Future<void> getLastFiveDays() async {
    final token = await SharedPrefsHelper.getToken();
    if (token == null) return;

    _lastFiveDays = await _apiService.getLastFiveDays(token);
    notifyListeners();
  }

  Future<void> getLokasiKantor() async {
    final token = await SharedPrefsHelper.getToken();
    if (token == null) return;

    _lokasiKantor = await _apiService.getLokasiKantor(token);
    notifyListeners();
  }
}
