import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/session_provider.dart';
import '../routes.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/error_messages.dart';
import '../widgets/app_button.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _birthdateController;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _lastNameController = TextEditingController();
    _birthdateController = TextEditingController();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _lastNameController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name')?.trim() ?? '';
    final email = prefs.getString('user_email')?.trim() ?? '';
    final lastName = prefs.getString('user_last_name')?.trim() ?? '';
    final birthdate = prefs.getString('user_birthdate')?.trim() ?? '';

    _nameController.text = name.isNotEmpty ? name : 'Usuario';
    _emailController.text = email.isNotEmpty ? email : 'correo@ejemplo.com';
    _lastNameController.text = lastName;
    _birthdateController.text = birthdate;

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final lastName = _lastNameController.text.trim();
    final birthdate = _birthdateController.text.trim();

    if (name.isEmpty || lastName.isEmpty || email.isEmpty || birthdate.isEmpty) {
      _showMessage('Completa todos los campos');
      return;
    }

    if (!_isValidEmail(email)) {
      _showMessage('Correo electronico invalido');
      return;
    }

    final parsedBirthdate = DateTime.tryParse(birthdate);
    if (parsedBirthdate == null) {
      _showMessage('Fecha de nacimiento invalida');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        _showMessage('Sesion expirada, inicia sesion');
        return;
      }

      await AuthService.updateProfile(
        token: token,
        nombre: name,
        apellidos: lastName,
        fechaNac: _formatDate(parsedBirthdate),
        correo: email,
      );

      await prefs.setString('user_name', name);
      await prefs.setString('user_email', email);
      await prefs.setString('user_last_name', lastName);
      await prefs.setString('user_birthdate', _formatDate(parsedBirthdate));

      _showMessage('Perfil actualizado');
    } catch (e) {
      _showMessage(friendlyMessage(e));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleLogout() async {
    if (_isLoggingOut) return;

    final sessionProvider = context.read<SessionProvider>();
    setState(() => _isLoggingOut = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    try {
      if (token != null && token.isNotEmpty) {
        await AuthService.logout(token: token);
      }
    } catch (e) {
      debugPrint('Error cerrando sesion en backend: $e');
    } finally {
      await sessionProvider.clear();
      await prefs.remove('user_last_name');
      await prefs.remove('user_birthdate');

      if (mounted) {
        setState(() => _isLoggingOut = false);
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool _isValidEmail(String value) {
    final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return pattern.hasMatch(value);
  }

  Future<void> _selectBirthdate() async {
    final current = DateTime.tryParse(_birthdateController.text.trim());
    final initialDate = current ?? DateTime(2000, 1, 1);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime.now(),
    );

    if (picked == null) return;
    _birthdateController.text = _formatDate(picked);
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = context.watch<SessionProvider>().isGuest;

    return AppScaffold(
      showMenu: true,
      title: const Text('Mi Perfil'),
      body: isGuest ? _GuestProfileState(onLogin: () {
              Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
            }) : _buildAccountForm(context),
    );
  }

  Widget _buildAccountForm(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.beige,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.grayLight),
              ),
              child: Text(
                'Aqui puedes revisar tus datos de cuenta, actualizarlos y cerrar sesion.',
                style: AppTextStyles.body,
              ),
            ),
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.grayLight,
                    borderRadius: BorderRadius.circular(45),
                  ),
                  child: const Icon(Icons.person, size: 46, color: AppColors.grayDark),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.camera_alt, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Nombre de Usuario', style: AppTextStyles.body),
            ),
            const SizedBox(height: 6),
            AppTextField(
              hintText: 'Nombre de Usuario',
              prefixIcon: Icons.person,
              controller: _nameController,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Apellidos', style: AppTextStyles.body),
            ),
            const SizedBox(height: 6),
            AppTextField(
              hintText: 'Apellidos',
              prefixIcon: Icons.person_outline,
              controller: _lastNameController,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Fecha de nacimiento', style: AppTextStyles.body),
            ),
            const SizedBox(height: 6),
            AppTextField(
              hintText: 'YYYY-MM-DD',
              prefixIcon: Icons.calendar_today,
              controller: _birthdateController,
              keyboardType: TextInputType.datetime,
              readOnly: true,
              onTap: _selectBirthdate,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Correo electronico', style: AppTextStyles.body),
            ),
            const SizedBox(height: 6),
            AppTextField(
              hintText: 'Correo electronico',
              prefixIcon: Icons.email,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 20),
            AppButton.primary(
              label: _isSaving ? 'Guardando...' : 'Guardar cambios',
              onPressed: _isLoading ? null : _handleSave,
            ),
            const SizedBox(height: 12),
            AppButton.danger(
              label: _isLoggingOut ? 'Cerrando...' : 'Cerrar sesion',
              onPressed: _isLoggingOut ? null : _handleLogout,
            ),
          ],
        ),
      );
  }
}

class _GuestProfileState extends StatelessWidget {
  const _GuestProfileState({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_outline, size: 72, color: AppColors.grayDark),
            const SizedBox(height: 16),
            Text('Estás en modo invitado', style: AppTextStyles.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Inicia sesión para ver y actualizar los datos de tu cuenta. En modo invitado el '
              'historial se guarda solo en este dispositivo.',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            AppButton.primary(label: 'Iniciar sesión', onPressed: onLogin),
          ],
        ),
      ),
    );
  }
}
