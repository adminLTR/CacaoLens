import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/session_provider.dart';
import '../routes.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/error_messages.dart';
import '../utils/responsive.dart';
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
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = isCompact(context);

    return AppScaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: compact ? 18 : 28, vertical: 40),
        child: Column(
          children: [
            const AppLogo(),
            const SizedBox(height: 24),
            AppTextField(
              hintText: 'Email',
              prefixIcon: Icons.email,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
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
              label: _isLoading ? 'Ingresando...' : 'Iniciar sesion',
              onPressed: _handleLogin,
            ),
            const SizedBox(height: 12),
            AppButton.secondary(
              label: 'Registrarse',
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.register),
            ),
            const SizedBox(height: 12),
            AppButton.neutral(
              label: 'Entrar como invitado',
              onPressed: () async {
                await context.read<SessionProvider>().refresh();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.home);
                }
              },
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
              'Analiza el estado del cacao al instante',
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Completa correo y contrasena');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await AuthService.login(email: email, password: password);
      final token = response['token']?.toString();
      final usuario = response['usuario'] as Map<String, dynamic>?;

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        if (usuario != null) {
          await prefs.setString('user_email', usuario['correo']?.toString() ?? '');
          await prefs.setString('user_name', usuario['nombre']?.toString() ?? '');
        }
      }

      if (!mounted) return;
      await context.read<SessionProvider>().refresh();

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } catch (e) {
      _showMessage(friendlyMessage(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
