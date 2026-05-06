import 'package:flutter/material.dart';

import '../routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_logo.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
        child: Column(
          children: [
            const AppLogo(),
            const SizedBox(height: 24),
            AppTextField(
              hintText: 'Email',
              prefixIcon: Icons.email,
              controller: _emailController,
            ),
            const SizedBox(height: 14),
            AppTextField(
              hintText: 'Contrasena',
              prefixIcon: Icons.lock,
              controller: _passwordController,
              obscureText: _obscurePassword,
              suffix: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                color: AppColors.green,
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            const SizedBox(height: 22),
            AppButton.primary(
              label: 'Iniciar sesion',
              onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.home),
            ),
            const SizedBox(height: 12),
            AppButton.secondary(
              label: 'Registrarse',
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.register),
            ),
            const SizedBox(height: 12),
            AppButton.neutral(
              label: 'Entrar como invitado',
              onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.home),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.recover),
              child: Text(
                'Olvidaste tu contrasena?',
                style: AppTextStyles.body.copyWith(color: AppColors.green),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Analiza la calidad del cacao al instante',
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
