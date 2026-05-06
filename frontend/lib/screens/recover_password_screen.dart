import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_text_field.dart';

class RecoverPasswordScreen extends StatelessWidget {
  const RecoverPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showBack: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: Column(
          children: [
            const Icon(Icons.lock_outline, size: 80),
            const SizedBox(height: 16),
            Text('Recuperar Contrasena', style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Ingresa el correo asociado a tu cuenta y te enviaremos un enlace',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            const AppTextField(hintText: 'Email', prefixIcon: Icons.email),
            const SizedBox(height: 20),
            AppButton.secondary(
              label: 'Recuperar contrasena',
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }
}
