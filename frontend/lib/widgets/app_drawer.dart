import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/session_provider.dart';
import '../routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final displayName = (session.userName != null && session.userName!.trim().isNotEmpty)
        ? session.userName!.trim()
        : (session.userEmail != null && session.userEmail!.trim().isNotEmpty)
            ? session.userEmail!.trim()
            : 'Invitado';

    return Drawer(
      backgroundColor: AppColors.cream,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            color: AppColors.brown,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.coffee, color: AppColors.white, size: 32),
                const SizedBox(height: 10),
                const Text(
                  'CacaoLens',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  session.isGuest ? 'Invitado' : displayName,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: session.isGuest ? AppColors.gray : AppColors.green,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    session.isGuest ? 'Modo invitado' : 'Sesión iniciada',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _DrawerItem(
            label: 'Inicio',
            icon: Icons.home,
            route: AppRoutes.home,
            isActive: currentRoute == AppRoutes.home,
          ),
          _DrawerItem(
            label: 'Camara',
            icon: Icons.camera_alt,
            route: AppRoutes.camera,
            isActive: currentRoute == AppRoutes.camera,
          ),
          _DrawerItem(
            label: 'Historial',
            icon: Icons.history,
            route: AppRoutes.history,
            isActive: currentRoute == AppRoutes.history,
          ),
          _DrawerItem(
            label: 'Configuracion',
            icon: Icons.settings,
            route: AppRoutes.settings,
            isActive: currentRoute == AppRoutes.settings,
          ),
          _DrawerItem(
            label: 'Mi perfil',
            icon: Icons.person,
            route: AppRoutes.profile,
            isActive: currentRoute == AppRoutes.profile,
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.label,
    required this.icon,
    required this.route,
    required this.isActive,
  });

  final String label;
  final IconData icon;
  final String route;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? AppColors.beige : Colors.transparent,
        border: Border(
          left: BorderSide(
            color: isActive ? AppColors.green : Colors.transparent,
            width: 4,
          ),
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: isActive ? AppColors.green : AppColors.brown),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            color: isActive ? AppColors.green : null,
          ),
        ),
        onTap: () {
          Navigator.of(context).pop();
          if (!isActive) {
            Navigator.of(context).pushReplacementNamed(route);
          }
        },
      ),
    );
  }
}
