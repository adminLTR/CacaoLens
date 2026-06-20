import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/logo.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 8),
        RichText(
          text: const TextSpan(
            text: 'Cacao',
            style: TextStyle(
              color: AppColors.brown,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
            children: [
              TextSpan(
                text: 'Lens',
                style: TextStyle(color: AppColors.green),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
