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
      final response = await _dio.post(
        '/api/auth/login',
        data: {'username': username, 'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response?.data ??
            {'success': false, 'message': 'Kesalahan server'};
      }
      return {'success': false, 'message': 'Tidak bisa terhubung ke server'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ===== User Profile =====
  Future<Map<String, dynamic>> getUserProfile(String token) async {
    try {
      final response = await _dio.get(
        '/api/user/profile',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException {
      return {};
    }
  }

  // ===== Absen Masuk (Check-in) =====
  Future<Map<String, dynamic>> absenMasuk(String token, String type) async {
    try {
      final response = await _dio.post(
        '/api/absensi/checkin',
        data: {"type": type}, // "in" atau "out"
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return {
          "status": "failed",
          "message": "Gagal koneksi server (${response.statusCode})"
        };
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response?.data ??
            {"status": "failed", "message": "Kesalahan server"};
      } else {
        return {
          "status": "failed",
          "message": "Tidak bisa terhubung ke server"
        };
      }
    } catch (e) {
      return {"status": "failed", "message": "Error: $e"};
    }
  }

  // ===== Jadwal Hari Ini =====
  Future<Map<String, dynamic>> getJadwalToday(String token) async {
    try {
      final response = await _dio.get(
        "/api/absensi/today",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      return response.data;
    } on DioException {
      return {};
    }
  }

  // ===== Ringkasan Bulanan =====
  Future<Map<String, dynamic>> getMonthlySummary(String token) async {
    try {
      final response = await _dio.get(
        "/api/absensi/summary",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      return response.data;
    } on DioException {
      return {};
    }
  }

  // ===== 5 Hari Terakhir =====
  Future<List<Map<String, dynamic>>> getLastFiveDays(String token) async {
    try {
      final response = await _dio.get(
        "/api/absensi/last5days",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (response.statusCode == 200) {
        final data = response.data as List;
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } on DioException {
      return [];
    }
  }

  // ===== Lokasi Kantor =====
  Future<List<Map<String, dynamic>>> getLokasiKantor(String token) async {
    try {
      final response = await _dio.get(
        '/api/absensi/kantor',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data['kantor'] != null) {
        final List data = response.data['kantor'];
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<bool> hasInternetConnection() async {
    try {
      final response = await Dio().get('https://google.com').timeout(
            const Duration(seconds: 3),
          );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // Cek koneksi server backend
  Future<bool> hasServerConnection() async {
    try {
      final response = await Dio().get('${ApiConfig.baseUrl}/ping').timeout(
            const Duration(seconds: 3),
          );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
