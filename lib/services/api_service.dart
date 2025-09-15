import 'package:dio/dio.dart';
import '../config/api_config.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: ApiConfig.connectTimeout,
    receiveTimeout: ApiConfig.receiveTimeout,
  ));

  // ===== Login =====
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      Response response = await _dio.post('/auth/login', data: {
        'username': username,
        'password': password,
      });
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response?.data ??
            {
              'success': false,
              'message': 'Login gagal, periksa username/password.'
            };
      } else {
        return {'success': false, 'message': 'Tidak bisa terhubung ke server.'};
      }
    }
  }

  // ===== Jadwal & Absensi Hari Ini =====
  Future<Map<String, dynamic>> getJadwalToday(String token) async {
    try {
      final response = await _dio.get(
        "/absensi/jadwalToday",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List && data.isNotEmpty) return data[0];
      }
      return {};
    } on DioException catch (e) {
      print("Error getJadwalToday: ${e.message}");
      return {};
    }
  }

  // ===== Ringkasan Bulanan =====
  Future<Map<String, dynamic>> getMonthlySummary(String token) async {
    try {
      final response = await _dio.get(
        "/absensi/monthlySummary",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] ?? {};
      }
      return {};
    } on DioException catch (e) {
      print("Error getMonthlySummary: ${e.message}");
      return {};
    }
  }

  // ===== 5 Hari Terakhir =====
  Future<List<Map<String, dynamic>>> getLastFiveDays(String token) async {
    try {
      final response = await _dio.get(
        "/absensi/lastfiveDays",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } on DioException catch (e) {
      print("Error getLastFiveDays: ${e.message}");
      return [];
    }
  }

  // ===== User Profile =====
  Future<Map<String, dynamic>> getUserProfile(String token) async {
    try {
      final response = await _dio.get(
        '/user/profile',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data['data'] ?? {};
    } catch (e) {
      print('getUserProfile error: $e');
      return {};
    }
  }

  // ===== Quick Absen =====
  Future<bool> quickAbsen(String token) async {
    try {
      final response = await _dio.post('/quick_absen',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      return response.data['success'] == true;
    } catch (e) {
      print('quickAbsen error: $e');
      return false;
    }
  }

  // ===== Ping Server =====
  Future<bool> pingServer() async {
    try {
      final response = await _dio.get('/ping');
      print('Ping response: ${response.data}');
      return response.data['status'] == 'success';
    } catch (e) {
      print('Ping error: $e');
      return false;
    }
  }
}
