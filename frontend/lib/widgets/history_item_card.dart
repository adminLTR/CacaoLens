import 'package:flutter/material.dart';

import '../models/history_item.dart';
import '../theme/app_colors.dart';
import 'status_pill.dart';

class HistoryItemCard extends StatelessWidget {
  const HistoryItemCard({super.key, required this.item});

  final HistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grayLight,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.gray),
            ),
            child: const Icon(Icons.image, color: AppColors.grayDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fecha: ${item.date}', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text('Estado: '),
                    StatusPill(label: item.status, color: item.statusColor),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Confianza: ${item.confidence}%'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
