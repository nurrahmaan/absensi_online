import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/shared_prefs_helper.dart';

class UserProvider with ChangeNotifier {
  Map<String, dynamic> userProfile = {};
  bool isLoading = false;

  final ApiService _apiService = ApiService();

  Future<void> loadUserProfile() async {
    isLoading = true;
    notifyListeners();

    try {
      // Ambil token dari SharedPrefs
      String? token = await SharedPrefsHelper.getToken();
      if (token != null) {
        final data = await _apiService.getUserProfile(token);
        userProfile = data;
      }
    } catch (e) {
      print("Error loadUserProfile: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
