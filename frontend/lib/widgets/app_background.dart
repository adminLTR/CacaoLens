import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.cream, AppColors.beige],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Positioned(
          top: -40,
          left: -30,
          child: _LeafBlob(size: 140, opacity: 0.12),
        ),
        Positioned(
          top: 120,
          right: -40,
          child: _LeafBlob(size: 160, opacity: 0.12),
        ),
        Positioned(
          bottom: -20,
          left: -10,
          child: _LeafBlob(size: 180, opacity: 0.15),
        ),
        Positioned(
          bottom: 40,
          right: -30,
          child: _LeafBlob(size: 140, opacity: 0.12),
        ),
        child,
      ],
    );
  }
}

class _LeafBlob extends StatelessWidget {
  const _LeafBlob({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: size,
        height: size * 0.7,
        decoration: BoxDecoration(
          color: AppColors.brown,
          borderRadius: BorderRadius.circular(size),
        ),
      ),
    );
  }
}
