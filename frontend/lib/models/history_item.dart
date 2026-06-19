import 'dart:convert';
import 'package:flutter/material.dart';

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

  Color get statusColor {
    final normalized = status.toUpperCase();
    if (normalized.contains('PUDRIC') || normalized.contains('BORER')) {
      return Colors.redAccent;
    }
    return Colors.green;
  }

  String get dateFormatted {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'status': status,
      'confidence': confidence,
      'date': date.toIso8601String(),
    };
  }

  factory HistoryItem.fromMap(Map<String, dynamic> map) {
    return HistoryItem(
      id: map['id'] ?? '',
      imagePath: map['imagePath'] ?? '',
      status: map['status'] ?? 'DESCONOCIDO',
      confidence: map['confidence']?.toDouble() ?? 0.0,
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());
  factory HistoryItem.fromJson(String source) => HistoryItem.fromMap(json.decode(source));
}
