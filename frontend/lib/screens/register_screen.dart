import 'package:flutter/material.dart';

import '../routes.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_logo.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showBack: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: Column(
          children: [
            const AppLogo(size: 80),
            const SizedBox(height: 20),
            AppTextField(
              hintText: 'Nombre de Usuario',
              prefixIcon: Icons.person,
              controller: _nameController,
            ),
            const SizedBox(height: 12),
            AppTextField(
              hintText: 'Email',
              prefixIcon: Icons.email,
              controller: _emailController,
            ),
            const SizedBox(height: 12),
            AppTextField(
              hintText: 'Contrasena',
              prefixIcon: Icons.lock,
              controller: _passwordController,
              obscureText: _obscurePassword,
              suffix: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            const SizedBox(height: 12),
            AppTextField(
              hintText: 'Confirmar contrasena',
              prefixIcon: Icons.lock,
              controller: _confirmController,
              obscureText: _obscureConfirm,
              suffix: IconButton(
                icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            const SizedBox(height: 20),
            AppButton.primary(
              label: 'Crear cuenta',
              onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.home),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Ya tienes cuenta?', style: AppTextStyles.body),
            ),
            const SizedBox(height: 12),
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
