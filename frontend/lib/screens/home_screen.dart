import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../routes.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_logo.dart';
import '../widgets/app_scaffold.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _displayName = 'Usuario';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('user_name');
    final fallbackEmail = prefs.getString('user_email');
    final nextName = (savedName != null && savedName.trim().isNotEmpty)
        ? savedName.trim()
        : (fallbackEmail != null && fallbackEmail.trim().isNotEmpty)
            ? fallbackEmail.trim()
            : 'Usuario';

    if (!mounted) return;
    setState(() => _displayName = nextName);
  }

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
            Text('Bienvenido, $_displayName!', style: AppTextStyles.titleMedium),
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
              onPressed: () => _pickFromGallery(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null && context.mounted) {
      Navigator.of(context).pushNamed(AppRoutes.preview, arguments: image.path);
    }
  }
}
