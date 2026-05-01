import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_scaffold.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showMenu: true,
      title: const Text('Resultados'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.grayLight,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.grayDark),
              ),
              child: Column(
                children: [
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(Icons.image, size: 72, color: AppColors.grayDark),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text('SALUDABLE', style: AppTextStyles.titleLarge.copyWith(color: AppColors.green)),
                  const SizedBox(height: 6),
                  Text('Confianza: 96.5%', style: AppTextStyles.body),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: 0.965,
                      minHeight: 14,
                      color: AppColors.green,
                      backgroundColor: AppColors.gray,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppButton.primary(label: 'Guardar', onPressed: () {}),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton.secondary(label: 'Exportar', onPressed: () {}),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
