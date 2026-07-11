import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class FlowStepper extends StatelessWidget {
  const FlowStepper({super.key, required this.currentStep});

  /// 1-based index of the current step (1 = Foto, 2 = Vista previa, 3 = Resultado).
  final int currentStep;

  static const _labels = ['Foto', 'Vista previa', 'Resultado'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(_labels.length * 2 - 1, (index) {
          if (index.isOdd) {
            final leftStep = (index ~/ 2) + 1;
            final connectorDone = currentStep > leftStep;
            return Expanded(
              child: Container(
                height: 2,
                color: connectorDone ? AppColors.green : AppColors.grayLight,
              ),
            );
          }

          final step = (index ~/ 2) + 1;
          final isDone = step < currentStep;
          final isActive = step == currentStep;
          final circleColor = isDone || isActive ? AppColors.green : AppColors.grayLight;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
                child: isDone
                    ? const Icon(Icons.check, size: 16, color: AppColors.white)
                    : Text(
                        '$step',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
              const SizedBox(height: 4),
              Text(
                _labels[step - 1],
                style: AppTextStyles.body.copyWith(
                  fontSize: 11,
                  color: isActive ? AppColors.green : AppColors.grayDark,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
