import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class HistoryProvider extends ChangeNotifier {
  final ApiService api;
  final String token;

  HistoryProvider({required this.api, required this.token}) {
    fetchHistory();
  }

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  bool loading = false;
  List<Map<String, dynamic>> history = [];

  void setMonth(int month) {
    selectedMonth = month;
    fetchHistory();
  }

  void setYear(int year) {
    selectedYear = year;
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    loading = true;
    notifyListeners();

    try {
      // print("Fetching history for month: $selectedMonth, year: $selectedYear");
      final response = await api.getHistory(
        token,
        month: selectedMonth,
        year: selectedYear,
      );
      // print("API response: $response"); // <-- log respon dari server

      if (response['history'] != null) {
        history = List<Map<String, dynamic>>.from(response['history']);
      } else {
        history = [];
      }
    } catch (e) {
      history = [];
      print("fetchHistory error: $e");
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
