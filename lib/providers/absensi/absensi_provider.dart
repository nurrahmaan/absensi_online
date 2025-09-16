import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/shared_prefs_helper.dart';

class AbsensiProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  Map<String, dynamic> _todayData = {};
  Map<String, dynamic> _monthlySummary = {};
  List<Map<String, dynamic>> _lastFiveDays = [];
  bool _isLoading = false;

  Map<String, dynamic> get todayData => _todayData;
  Map<String, dynamic> get monthlySummary => _monthlySummary;
  List<Map<String, dynamic>> get lastFiveDays => _lastFiveDays;
  bool get isLoading => _isLoading;

  Future<void> loadAllData() async {
    _isLoading = true;
    notifyListeners();

    final token = await SharedPrefsHelper.getToken();
    if (token != null) {
      await fetchToday(token);
      await fetchMonthlySummary(token);
      await fetchLastFiveDays(token);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchToday(String token) async {
    try {
      final data = await _apiService.getJadwalToday(token);
      _todayData = data.isNotEmpty ? data : {};
    } catch (_) {
      _todayData = {};
    }
    notifyListeners();
  }

  Future<void> fetchMonthlySummary(String token) async {
    try {
      final summary = await _apiService.getMonthlySummary(token);
      _monthlySummary = {
        'hadir': int.tryParse(summary['hadir']?.toString() ?? '0') ?? 0,
        'alpha': int.tryParse(summary['alpha']?.toString() ?? '0') ?? 0,
        'telat': int.tryParse(summary['telat']?.toString() ?? '0') ?? 0,
        'piket': int.tryParse(summary['piket']?.toString() ?? '0') ?? 0,
      };
    } catch (_) {
      _monthlySummary = {};
    }
    notifyListeners();
  }

  Future<void> fetchLastFiveDays(String token) async {
    try {
      final data = await _apiService.getLastFiveDays(token);
      _lastFiveDays = data;
    } catch (_) {
      _lastFiveDays = [];
    }
    notifyListeners();
  }
}
