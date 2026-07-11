import 'package:flutter/material.dart';

import '../routes.dart';
import '../services/auth_service.dart';
import '../theme/app_text_styles.dart';
import '../utils/error_messages.dart';
import '../utils/responsive.dart';
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
  final _lastNameController = TextEditingController();
  final _dniController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _dniController.dispose();
    _birthdateController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = isCompact(context);

    return AppScaffold(
      showBack: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: compact ? 18 : 28, vertical: 32),
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
              hintText: 'Apellidos',
              prefixIcon: Icons.person_outline,
              controller: _lastNameController,
            ),
            const SizedBox(height: 12),
            AppTextField(
              hintText: 'DNI',
              prefixIcon: Icons.badge,
              controller: _dniController,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 12),
            AppTextField(
              hintText: 'Fecha de nacimiento (YYYY-MM-DD)',
              prefixIcon: Icons.calendar_today,
              controller: _birthdateController,
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 12),
            AppTextField(
              hintText: 'Email',
              prefixIcon: Icons.email,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
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
              label: _isLoading ? 'Creando...' : 'Crear cuenta',
              onPressed: _handleRegister,
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Ya tienes cuenta?', style: AppTextStyles.body),
            ),
            const SizedBox(height: 12),
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

  Future<void> _handleRegister() async {
    if (_isLoading) return;

    final nombre = _nameController.text.trim();
    final apellidos = _lastNameController.text.trim();
    final dni = _dniController.text.trim();
    final fechaNac = _birthdateController.text.trim();
    final correo = _emailController.text.trim();
    final contrasena = _passwordController.text;
    final confirm = _confirmController.text;

    if ([nombre, apellidos, dni, fechaNac, correo, contrasena, confirm].any((v) => v.isEmpty)) {
      _showMessage('Completa todos los campos');
      return;
    }

    if (contrasena != confirm) {
      _showMessage('Las contrasenas no coinciden');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService.register(
        nombre: nombre,
        apellidos: apellidos,
        fechaNac: fechaNac,
        dni: dni,
        correo: correo,
        contrasena: contrasena,
      );

      if (!mounted) return;
      _showMessage('Cuenta creada, inicia sesion');
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
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
