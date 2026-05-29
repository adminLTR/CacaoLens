import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_item.dart';

class HistoryProvider extends ChangeNotifier {
  List<HistoryItem> _history = [];
  List<HistoryItem> get history => _history;

  HistoryProvider() {
    loadHistory();
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyData = prefs.getStringList('cacao_history') ?? [];
    
    _history = historyData.map((item) => HistoryItem.fromJson(item)).toList();
    notifyListeners();
  }

  Future<void> saveResult(HistoryItem item) async {
    _history.insert(0, item);
    
    final prefs = await SharedPreferences.getInstance();
    final historyData = _history.map((i) => i.toJson()).toList();
    
    await prefs.setStringList('cacao_history', historyData);
    notifyListeners();
  }
}