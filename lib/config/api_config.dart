class ApiConfig {
  static const String baseUrl =
      // "http://172.20.10.6:3000/api"; // ganti sesuai servermu
      "http://192.168.1.3:3000/api"; // ganti sesuai servermu
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
