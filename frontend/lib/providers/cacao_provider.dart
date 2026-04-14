import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CacaoProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _cacaoList = [];
  Map<String, dynamic>? _currentCacao;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get cacaoList => _cacaoList;
  Map<String, dynamic>? get currentCacao => _currentCacao;

  Future<void> fetchCacaoList() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cacaoList = await _apiService.getCacaoList();
      _error = null;
    } catch (e) {
      _error = 'Error fetching cacao list: $e';
      _cacaoList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getCacaoById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentCacao = await _apiService.getCacaoById(id);
      _error = null;
    } catch (e) {
      _error = 'Error fetching cacao: $e';
      _currentCacao = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createCacao(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.createCacao(data);
      _currentCacao = result;
      _error = null;
      await fetchCacaoList(); // Refresh list
    } catch (e) {
      _error = 'Error creating cacao: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
