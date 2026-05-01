import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
    this.textColor = Colors.white,
    this.width,
  });

  factory AppButton.primary({
    required String label,
    required VoidCallback onPressed,
    double? width,
  }) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      backgroundColor: AppColors.green,
      width: width,
    );
  }

  factory AppButton.secondary({
    required String label,
    required VoidCallback onPressed,
    double? width,
  }) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      backgroundColor: AppColors.orange,
      width: width,
    );
  }

  factory AppButton.neutral({
    required String label,
    required VoidCallback onPressed,
    double? width,
  }) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      backgroundColor: AppColors.gray,
      width: width,
    );
  }

  factory AppButton.danger({
    required String label,
    required VoidCallback onPressed,
    double? width,
  }) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      backgroundColor: AppColors.red,
      width: width,
    );
  }

  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: const StadiumBorder(),
          elevation: 3,
        ),
        onPressed: onPressed,
        child: Text(label, style: AppTextStyles.button),
      ),
    );
  }
}
