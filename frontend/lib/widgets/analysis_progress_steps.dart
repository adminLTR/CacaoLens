import 'package:flutter/material.dart';

import '../models/analysis_result.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AnalysisProgressSteps extends StatelessWidget {
  const AnalysisProgressSteps({super.key, required this.stage});

  final AnalysisStage stage;

  static const _steps = [
    (AnalysisStage.uploading, 'Subiendo imagen...'),
    (AnalysisStage.analyzing, 'Analizando con IA...'),
    (AnalysisStage.generatingResult, 'Generando resultado...'),
  ];

  int get _activeIndex {
    switch (stage) {
      case AnalysisStage.idle:
        return -1;
      case AnalysisStage.uploading:
        return 0;
      case AnalysisStage.analyzing:
        return 1;
      case AnalysisStage.generatingResult:
        return 2;
      case AnalysisStage.done:
      case AnalysisStage.error:
        return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = _activeIndex;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < _steps.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: i < active
                      ? const Icon(Icons.check_circle, color: AppColors.green, size: 22)
                      : i == active
                          ? const CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.white)
                          : Icon(Icons.circle_outlined, color: AppColors.white.withValues(alpha: 0.5), size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  _steps[i].$2,
                  style: AppTextStyles.body.copyWith(
                    color: i <= active ? AppColors.white : AppColors.white.withValues(alpha: 0.6),
                    fontWeight: i == active ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
