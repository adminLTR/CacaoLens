import 'package:flutter/material.dart';

class HistoryItem {
  const HistoryItem({
    required this.date,
    required this.status,
    required this.confidence,
    required this.statusColor,
  });

  final String date;
  final String status;
  final double confidence;
  final Color statusColor;
}
