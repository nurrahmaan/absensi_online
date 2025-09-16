import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class DashboardProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  Map<String, dynamic> userProfile = {};
  Map<String, dynamic> jadwalToday = {};
  Map<String, dynamic> monthlySummary = {};
  List<Map<String, dynamic>> lastFiveDays = [];

  bool isLoading = false;

  Future<void> fetchAllData(String token) async {
    isLoading = true;
    notifyListeners();

    try {
      userProfile = await _apiService.getUserProfile(token);
      jadwalToday = await _apiService.getJadwalToday(token);
      monthlySummary = await _apiService.getMonthlySummary(token);
      lastFiveDays = await _apiService.getLastFiveDays(token);
    } catch (e) {
      print("Dashboard fetchAllData error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
