import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ApiService api;
  final String token;

  Map<String, dynamic> profile = {};
  bool loading = false;

  ProfileProvider({required this.api, required this.token});

  Future<void> fetchProfile() async {
    loading = true;
    notifyListeners();

    final data = await api.getUserProfile(token);
    profile = data;

    loading = false;
    notifyListeners();
  }
}
