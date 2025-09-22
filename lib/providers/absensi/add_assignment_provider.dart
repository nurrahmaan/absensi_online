import 'package:absensi_online/services/api_service.dart';
import 'package:flutter/material.dart';

class AddAssignmentProvider extends ChangeNotifier {
  final String token;

  AddAssignmentProvider({required this.token}) {
    fetchKaryawan();
  }

  bool isLoadingKaryawan = true;
  bool isSubmitting = false;

  List<Map<String, dynamic>> karyawanList = [];
  String? selectedKaryawanId;
  String? kategori;
  String? dihari;

  /// Ambil karyawan dari API
  Future<void> fetchKaryawan() async {
    try {
      isLoadingKaryawan = true;
      notifyListeners();

      final res = await ApiService().getKaryawan(token);
      if (res['success'] == true && res['data'] != null) {
        karyawanList = List<Map<String, dynamic>>.from(res['data']);
      } else {
        karyawanList = [];
      }
    } catch (e) {
      print("Error fetchKaryawan: $e");
      karyawanList = [];
    } finally {
      isLoadingKaryawan = false;
      notifyListeners();
    }
  }

  /// Options untuk dropdown dihari
  List<String> getDihariOptions() {
    if (kategori?.toLowerCase() == "piket") return ["Libur"];
    if (kategori?.toLowerCase() == "lembur") return ["Kerja", "Libur"];
    return [];
  }

  /// Submit Assignment
  Future<Map<String, dynamic>> submitAssignment(
      Map<String, dynamic> payload) async {
    try {
      isSubmitting = true;
      notifyListeners();

      final res = await ApiService().addAssignment(payload, token);
      return res;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  /// Reset pilihan karyawan/kategori/dihari
  void resetSelections() {
    selectedKaryawanId = null;
    kategori = null;
    dihari = null;
    notifyListeners();
  }
}
