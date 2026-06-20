import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
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
    
    _history = historyData
        .map(_tryParseHistoryItem)
        .whereType<HistoryItem>()
        .toList();
    notifyListeners();
  }

  Future<void> saveResult(HistoryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final saveOriginals = prefs.getBool('settings_save_originals') ?? true;
    final itemToSave = saveOriginals ? await _copyImageForHistory(item) : item;

    _history.insert(0, itemToSave);

    final historyData = _history.map((i) => i.toJson()).toList();
    
    await prefs.setStringList('cacao_history', historyData);
    notifyListeners();
  }

  HistoryItem? _tryParseHistoryItem(String value) {
    try {
      return HistoryItem.fromJson(value);
    } catch (_) {
      return null;
    }
  }

  Future<HistoryItem> _copyImageForHistory(HistoryItem item) async {
    if (kIsWeb || item.imagePath.isEmpty) {
      return item;
    }

    final source = File(item.imagePath);
    if (!source.existsSync()) {
      return item;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final historyDirectory = Directory('${directory.path}/cacao_history');
      if (!historyDirectory.existsSync()) {
        historyDirectory.createSync(recursive: true);
      }

      final extension = item.imagePath.split('.').last;
      final targetPath = '${historyDirectory.path}/${item.id}.$extension';
      await source.copy(targetPath);

      return HistoryItem(
        id: item.id,
        imagePath: targetPath,
        status: item.status,
        confidence: item.confidence,
        date: item.date,
      );
    } catch (_) {
      return item;
    }
  }
}
