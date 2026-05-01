import 'package:flutter/material.dart';

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
  bool _offlineMode = true;
  String _quality = 'Alta';

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
              description: 'Guarda una copia de la foto en la galeria despues de analizarla',
              value: _saveOriginals,
              onChanged: (value) => setState(() => _saveOriginals = value),
            ),
            const SectionHeader(title: 'Conectividad'),
            SettingToggleTile(
              icon: Icons.cloud_off,
              title: 'Modo offline estricto',
              description: 'Desactiva intentos de conexion para ahorrar bateria',
              value: _offlineMode,
              onChanged: (value) => setState(() => _offlineMode = value),
            ),
            const SectionHeader(title: 'Procesamiento'),
            SettingDropdownTile(
              icon: Icons.settings,
              title: 'Calidad de imagen',
              description: 'Mayor calidad mejora la precision, pero tarda mas',
              value: _quality,
              items: const ['Alta', 'Media', 'Baja'],
              onChanged: (value) => setState(() => _quality = value ?? _quality),
            ),
          ],
        ),
      ),
    );
  }
}
