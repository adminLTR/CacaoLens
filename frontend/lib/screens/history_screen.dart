import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/history_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/history_item_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final historyProvider = Provider.of<HistoryProvider>(context);
    final items = historyProvider.history;

    return AppScaffold(
      showMenu: true,
      title: const Text('Historial de Análisis'),
      body: items.isEmpty 
        ? Center(
            child: Text(
              'Aún no tienes análisis guardados.',
              style: AppTextStyles.body.copyWith(color: AppColors.grayDark),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return HistoryItemCard(item: items[index]);
            },
          ),
    );
  }
}
