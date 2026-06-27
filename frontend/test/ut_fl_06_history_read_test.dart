// UT-FL-06: Verificar lectura de historial
// Basado en:
//   - lib/providers/history_provider.dart -> loadHistory()
//   - lib/models/history_item.dart -> fromJson() / toJson()
//
// El provider lee 'cacao_history' (List<String>) de SharedPreferences
// y lo parsea con HistoryItem.fromJson().

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Replica de HistoryItem (lib/models/history_item.dart) ---
class HistoryItem {
  final String id;
  final String imagePath;
  final String status;
  final double confidence;
  final DateTime date;

  const HistoryItem({
    required this.id,
    required this.imagePath,
    required this.status,
    required this.confidence,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'imagePath': imagePath,
        'status': status,
        'confidence': confidence,
        'date': date.toIso8601String(),
      };

  factory HistoryItem.fromMap(Map<String, dynamic> map) => HistoryItem(
        id: map['id'] ?? '',
        imagePath: map['imagePath'] ?? '',
        status: map['status'] ?? 'DESCONOCIDO',
        confidence: map['confidence']?.toDouble() ?? 0.0,
        date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      );

  String toJson() => json.encode(toMap());
  factory HistoryItem.fromJson(String source) =>
      HistoryItem.fromMap(json.decode(source));
}

// --- Replica de loadHistory() en HistoryProvider ---
HistoryItem? _tryParse(String value) {
  try {
    return HistoryItem.fromJson(value);
  } catch (_) {
    return null;
  }
}

Future<List<HistoryItem>> loadHistory() async {
  final prefs = await SharedPreferences.getInstance();
  final historyData = prefs.getStringList('cacao_history') ?? [];
  return historyData
      .map(_tryParse)
      .whereType<HistoryItem>()
      .toList();
}

void main() {
  group('UT-FL-06: Verificar lectura de historial', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Carga historial correctamente con dos entradas', () async {
      final item1 = HistoryItem(
        id: '1',
        imagePath: '/imgs/a.jpg',
        status: 'Saludable',
        confidence: 0.95,
        date: DateTime(2025, 6, 1),
      );
      final item2 = HistoryItem(
        id: '2',
        imagePath: '/imgs/b.jpg',
        status: 'Pudrición Negra',
        confidence: 0.87,
        date: DateTime(2025, 6, 2),
      );

      SharedPreferences.setMockInitialValues({
        'cacao_history': [item1.toJson(), item2.toJson()],
      });

      final history = await loadHistory();

      expect(history.length, equals(2));
      expect(history[0].status, equals('Saludable'));
      expect(history[1].status, equals('Pudrición Negra'));
    });

    test('Retorna lista vacía si no hay historial guardado', () async {
      final history = await loadHistory();
      expect(history, isEmpty);
    });

    test('HistoryItem.fromJson parsea correctamente', () {
      final item = HistoryItem(
        id: 'abc',
        imagePath: '/data/foto.png',
        status: 'Pod Borer',
        confidence: 0.72,
        date: DateTime(2025, 5, 15),
      );

      final parsed = HistoryItem.fromJson(item.toJson());

      expect(parsed.id, equals('abc'));
      expect(parsed.status, equals('Pod Borer'));
      expect(parsed.confidence, equals(0.72));
    });

    test('Status desconocido si el JSON no trae status', () {
      final json = '{"id":"3","imagePath":"","confidence":0.5,"date":"2025-01-01T00:00:00.000"}';
      final item = HistoryItem.fromJson(json);
      expect(item.status, equals('DESCONOCIDO'));
    });

    test('Entradas corruptas son ignoradas al cargar historial', () async {
      SharedPreferences.setMockInitialValues({
        'cacao_history': [
          'JSON_INVALIDO_!!',
          HistoryItem(
            id: '99',
            imagePath: '/img/ok.jpg',
            status: 'Saludable',
            confidence: 0.9,
            date: DateTime(2025, 6, 10),
          ).toJson(),
        ],
      });

      final history = await loadHistory();

      // La entrada corrupta fue ignorada, solo queda la válida
      expect(history.length, equals(1));
      expect(history[0].id, equals('99'));
    });

    test('confidence se convierte a double correctamente', () {
      final jsonStr =
          '{"id":"x","imagePath":"","status":"Saludable","confidence":0.88,"date":"2025-06-01T00:00:00.000"}';
      final item = HistoryItem.fromJson(jsonStr);
      expect(item.confidence, isA<double>());
      expect(item.confidence, equals(0.88));
    });
  });
}
