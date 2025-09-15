import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ServerConnectionProvider extends ChangeNotifier {
  bool _isConnected = true;
  bool _hasInternet = true;

  bool get isConnected => _isConnected;
  bool get hasInternet => _hasInternet;

  Timer? _timer;

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
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (!_hasInternet) {
          _hasInternet = true;
          notifyListeners();
        }
      }
    } catch (_) {
      if (_hasInternet) {
        _hasInternet = false;
        notifyListeners();
      }
    }
  }

  Future<void> _checkServer() async {
    // ganti dengan endpoint API backend kamu
    const url = "/ping";

    try {
      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 3),
          );

      if (response.statusCode == 200) {
        if (!_isConnected) {
          _isConnected = true;
          notifyListeners();
        }
      } else {
        if (_isConnected) {
          _isConnected = false;
          notifyListeners();
        }
      }
    } catch (_) {
      if (_isConnected) {
        _isConnected = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
