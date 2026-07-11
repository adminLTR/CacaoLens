import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/diagnosis.dart';
import '../models/history_item.dart';
import '../providers/history_provider.dart';
import '../providers/session_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/history_item_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DiagnosisCategory? _selectedFilter;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<HistoryItem> _applyFilters(List<HistoryItem> items) {
    return items.where((item) {
      final matchesFilter =
          _selectedFilter == null || item.diagnosisCategory == _selectedFilter;
      final matchesQuery = _query.isEmpty ||
          item.dateFormatted.toLowerCase().contains(_query.toLowerCase()) ||
          item.status.toLowerCase().contains(_query.toLowerCase());
      return matchesFilter && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allItems = context.watch<HistoryProvider>().history;
    final items = _applyFilters(allItems);
    final isGuest = context.watch<SessionProvider>().isGuest;

    return AppScaffold(
      showMenu: true,
      title: const Text('Historial de Análisis'),
      body: Column(
        children: [
          if (isGuest)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.beige,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.brown, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Estás en modo invitado: tu historial se guarda solo en este dispositivo.',
                      style: AppTextStyles.body.copyWith(fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Buscar por fecha o resultado',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _FilterChip(
                  label: 'Todos',
                  selected: _selectedFilter == null,
                  onSelected: () => setState(() => _selectedFilter = null),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Saludable',
                  selected: _selectedFilter == DiagnosisCategory.healthy,
                  onSelected: () => setState(() => _selectedFilter = DiagnosisCategory.healthy),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Pudrición Negra',
                  selected: _selectedFilter == DiagnosisCategory.blackPod,
                  onSelected: () => setState(() => _selectedFilter = DiagnosisCategory.blackPod),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Pod Borer',
                  selected: _selectedFilter == DiagnosisCategory.podBorer,
                  onSelected: () => setState(() => _selectedFilter = DiagnosisCategory.podBorer),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        allItems.isEmpty
                            ? 'Aún no tienes análisis guardados.'
                            : 'No hay resultados para este filtro.',
                        style: AppTextStyles.body.copyWith(color: AppColors.grayDark),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return HistoryItemCard(item: items[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onSelected});

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.green,
      labelStyle: TextStyle(
        color: selected ? AppColors.white : AppColors.grayDark,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: AppColors.grayLight,
    );
  }
}
