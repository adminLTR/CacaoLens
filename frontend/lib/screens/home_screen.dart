import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/history_item.dart';
import '../providers/history_provider.dart';
import '../routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/responsive.dart';
import '../widgets/app_button.dart';
import '../widgets/app_logo.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/history_item_card.dart';

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
    final history = context.watch<HistoryProvider>().history;
    final HistoryItem? lastItem = history.isNotEmpty ? history.first : null;
    final compact = isCompact(context);

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
            _MainActions(compact: compact),
            const SizedBox(height: 28),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Último análisis', style: AppTextStyles.titleMedium),
            ),
            const SizedBox(height: 12),
            lastItem != null
                ? InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.history),
                    child: HistoryItemCard(item: lastItem),
                  )
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.grayLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.image_search, size: 40, color: AppColors.grayDark),
                        const SizedBox(height: 10),
                        Text(
                          'Aún no tienes análisis guardados.',
                          style: AppTextStyles.body,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '¡Prueba tu primera foto!',
                          style: AppTextStyles.body.copyWith(color: AppColors.green),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
            if (lastItem != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pushNamed(AppRoutes.history),
                  child: const Text('Ver todo el historial'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MainActions extends StatelessWidget {
  const _MainActions({required this.compact});

  final bool compact;

  Future<void> _pickFromGallery(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null && context.mounted) {
      Navigator.of(context).pushNamed(AppRoutes.preview, arguments: image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final takePhoto = AppButton.primary(
      label: 'Tomar foto',
      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.camera),
    );
    final uploadImage = AppButton.secondary(
      label: 'Subir imagen',
      onPressed: () => _pickFromGallery(context),
    );

    if (compact) {
      return Column(
        children: [
          takePhoto,
          const SizedBox(height: 12),
          uploadImage,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: takePhoto),
        const SizedBox(width: 12),
        Expanded(child: uploadImage),
      ],
    );
  }
}
