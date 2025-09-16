import 'dart:async';
import 'package:flutter/foundation.dart';
import '/services/api_service.dart';

class ServerConnectionProvider extends ChangeNotifier {
  bool _isConnected = true;
  bool _hasInternet = true;

  bool get isConnected => _isConnected;
  bool get hasInternet => _hasInternet;

  Timer? _timer;
  final ApiService _apiService = ApiService();

  ServerConnectionProvider() {
    _startMonitoring();
  }

  void _startMonitoring() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await _checkInternet();
      await _checkServer();
    });
  }

  Future<void> _checkInternet() async {
    final connected = await _apiService.hasInternetConnection();
    if (_hasInternet != connected) {
      _hasInternet = connected;
      notifyListeners();
    }
  }

  Future<void> _checkServer() async {
    final connected = await _apiService.hasServerConnection();
    if (_isConnected != connected) {
      _isConnected = connected;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
