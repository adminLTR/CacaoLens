import 'package:flutter/material.dart';

import '../routes.dart';
import '../theme/app_colors.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.cream,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.brown),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.coffee, color: AppColors.white, size: 36),
                SizedBox(height: 12),
                Text(
                  'CacaoLens',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          _DrawerItem(
            label: 'Inicio',
            icon: Icons.home,
            route: AppRoutes.home,
          ),
          _DrawerItem(
            label: 'Camara',
            icon: Icons.camera_alt,
            route: AppRoutes.camera,
          ),
          _DrawerItem(
            label: 'Historial',
            icon: Icons.history,
            route: AppRoutes.history,
          ),
          _DrawerItem(
            label: 'Resultados',
            icon: Icons.analytics,
            route: AppRoutes.result,
          ),
          _DrawerItem(
            label: 'Configuracion',
            icon: Icons.settings,
            route: AppRoutes.settings,
          ),
          _DrawerItem(
            label: 'Mi perfil',
            icon: Icons.person,
            route: AppRoutes.profile,
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({required this.label, required this.icon, required this.route});

  final String label;
  final IconData icon;
  final String route;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.brown),
      title: Text(label),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacementNamed(route);
      },
    );
  }
}
