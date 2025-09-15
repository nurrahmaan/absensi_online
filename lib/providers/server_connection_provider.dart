import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ServerConnectionProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // Untuk menandai loading ping server (opsional)
  bool _loading = false;
  bool get loading => _loading;

  // Cek koneksi ke server
  Future<void> checkConnection() async {
    _loading = true;
    notifyListeners();

    try {
      final alive = await _apiService.pingServer();
      _isConnected = alive;
    } catch (e) {
      print('Ping error: $e');
      _isConnected = false;
    }

    _loading = false;
    notifyListeners();
  }

  // Bisa dipanggil untuk refresh koneksi
  Future<void> refreshConnection() async {
    await checkConnection();
  }
}
