import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../models/history_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class HistoryItemCard extends StatelessWidget {
  final HistoryItem item;

  const HistoryItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final localImageExists = item.imagePath.isNotEmpty &&
        !kIsWeb &&
        File(item.imagePath).existsSync();
    final webImageExists = item.imagePath.isNotEmpty && kIsWeb;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grayLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: localImageExists
                ? Image.file(
                    File(item.imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, color: AppColors.grayDark);
                    },
                  )
                : webImageExists
                    ? Image.network(
                        item.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image, color: AppColors.grayDark);
                        },
                      )
                : const Icon(Icons.image, color: AppColors.grayDark),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fecha: ${item.dateFormatted}', style: AppTextStyles.body),
                const SizedBox(height: 8),

                Row(
                  children: [
                    const Text('Estado: '),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.statusColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.status,
                        style: AppTextStyles.body.copyWith(color: AppColors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Text(
                  'Confianza: ${(item.confidence * 100).toStringAsFixed(1)}%',
                  style: AppTextStyles.body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
