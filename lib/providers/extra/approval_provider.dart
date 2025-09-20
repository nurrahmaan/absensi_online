import 'package:flutter/material.dart';
import '../../models/approval.dart';
import '../../services/api_service.dart';

class ApprovalProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Approval> _approvals = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Approval> get approvals => _approvals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchApprovals(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _approvals = await _apiService.getApprovals(token);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
