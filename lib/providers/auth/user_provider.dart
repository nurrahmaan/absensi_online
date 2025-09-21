import 'package:absensi_online/services/api_service.dart';
import 'package:absensi_online/utils/shared_prefs_helper.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  Map<String, dynamic> userProfile = {};
  bool isLoading = false;
  String? errorMessage;

  final ApiService _apiService = ApiService();

  Future<void> loadUserProfile() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      String? token = await SharedPrefsHelper.getToken();
      if (token != null) {
        final data = await _apiService.getUserProfile(token);
        userProfile = data;
      } else {
        errorMessage = "Token tidak ditemukan.";
      }
    } catch (e) {
      errorMessage = "Gagal memuat profil: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String get jabatan => userProfile['jabatan'] ?? '';
}
