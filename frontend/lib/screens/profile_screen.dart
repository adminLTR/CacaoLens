import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _user = const AppUser(name: 'Juan Perez', email: 'juanperez123@gmail.com');
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _user.name);
    _emailController = TextEditingController(text: _user.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showMenu: true,
      title: const Text('Mi Perfil'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          children: [
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
            ),
            const SizedBox(height: 20),
            AppButton.primary(
              label: 'Guardar cambios',
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            AppButton.danger(
              label: 'Cerrar sesion',
              onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.login),
            ),
          ],
        ),
      ),
    );
  }
}
