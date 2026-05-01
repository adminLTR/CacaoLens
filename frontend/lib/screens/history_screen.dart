import 'package:flutter/material.dart';

import '../models/history_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/history_item_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  List<HistoryItem> _items() {
    return const [
      HistoryItem(date: '21/04/2026', status: 'Pod Borer', confidence: 91.3, statusColor: Colors.red),
      HistoryItem(date: '23/04/2026', status: 'Pudricion negra', confidence: 92.8, statusColor: Colors.red),
      HistoryItem(date: '30/04/2026', status: 'Saludable', confidence: 96.5, statusColor: AppColors.green),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final items = _items();
    return AppScaffold(
      showMenu: true,
      title: const Text('Historial de Analisis'),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          Text('Historial de Analisis', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          for (final item in items) HistoryItemCard(item: item),
        ],
      ),
    );
  }
}
