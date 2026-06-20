import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_text_styles.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/section_header.dart';
import '../widgets/setting_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _saveOriginals = true;
  bool _offlineMode = false;
  String _quality = 'Alta';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;
    setState(() {
      _saveOriginals = prefs.getBool('settings_save_originals') ?? true;
      _offlineMode = prefs.getBool('settings_offline_mode') ?? false;
      _quality = prefs.getString('settings_image_quality') ?? 'Alta';
    });
  }

  Future<void> _setSaveOriginals(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('settings_save_originals', value);
    if (mounted) setState(() => _saveOriginals = value);
  }

  Future<void> _setOfflineMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('settings_offline_mode', value);
    if (mounted) setState(() => _offlineMode = value);
  }

  Future<void> _setQuality(String? value) async {
    if (value == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('settings_image_quality', value);
    if (mounted) setState(() => _quality = value);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showMenu: true,
      title: const Text('Configuracion'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Configuracion', style: AppTextStyles.titleMedium),
            const SectionHeader(title: 'Almacenamiento'),
            SettingToggleTile(
              icon: Icons.folder,
              title: 'Guardar fotos originales',
              description: 'Conserva una copia interna de la imagen al guardar el historial',
              value: _saveOriginals,
              onChanged: _setSaveOriginals,
            ),
            const SectionHeader(title: 'Conectividad'),
            SettingToggleTile(
              icon: Icons.cloud_off,
              title: 'Modo offline estricto',
              description: 'Usa solo el modelo local y no llama al backend',
              value: _offlineMode,
              onChanged: _setOfflineMode,
            ),
            const SectionHeader(title: 'Procesamiento'),
            SettingDropdownTile(
              icon: Icons.settings,
              title: 'Calidad de imagen',
              description: 'Mayor calidad mejora la precision, pero tarda mas',
              value: _quality,
              items: const ['Alta', 'Media', 'Baja'],
              onChanged: _setQuality,
            ),
          ],
        ),
      ),
    );
  }
}
