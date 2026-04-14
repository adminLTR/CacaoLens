import 'package:flutter/material.dart';
import 'dart:io';
import '../services/api_service.dart';

class AnalysisProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _currentAnalysis;
  List<Map<String, dynamic>> _analysisHistory = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get currentAnalysis => _currentAnalysis;
  List<Map<String, dynamic>> get analysisHistory => _analysisHistory;

  Future<void> analyzeImage(File imageFile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.analyzeImage(imageFile);
      _currentAnalysis = result;
      _error = null;
    } catch (e) {
      _error = 'Error analyzing image: $e';
      _currentAnalysis = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAnalysisHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _analysisHistory = await _apiService.getAnalysisHistory();
      _error = null;
    } catch (e) {
      _error = 'Error fetching history: $e';
      _analysisHistory = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAnalysisById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentAnalysis = await _apiService.getAnalysisById(id);
      _error = null;
    } catch (e) {
      _error = 'Error fetching analysis: $e';
      _currentAnalysis = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
