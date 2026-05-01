import 'package:flutter/material.dart';

import '../routes.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_logo.dart';
import '../widgets/app_scaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showMenu: true,
      title: const Text('CacaoLens'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: Column(
          children: [
            const AppLogo(size: 110),
            const SizedBox(height: 16),
            Text('Bienvenido, Usuario123!', style: AppTextStyles.titleMedium),
            const SizedBox(height: 12),
            Text(
              'Selecciona una imagen de cacao para empezar con la clasificacion',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton.primary(
              label: 'Usar camara',
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.camera),
            ),
            const SizedBox(height: 12),
            AppButton.secondary(
              label: 'Abrir galeria',
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.preview),
            ),
          ],
        ),
      ),
    );
  }
}
