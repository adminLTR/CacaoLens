import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 90});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.brown,
            borderRadius: BorderRadius.circular(size / 2),
          ),
          child: const Icon(Icons.camera, color: AppColors.white, size: 44),
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
