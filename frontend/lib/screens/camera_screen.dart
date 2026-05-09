import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/analysis_provider.dart';
import '../routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_scaffold.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  Future<void> _handleImageSelection(BuildContext context, ImageSource source) async {
    final provider = Provider.of<AnalysisProvider>(context, listen: false);
    await provider.pickImage(source);
    
    if (provider.selectedImage != null && context.mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showMenu: true,
      title: const Text('CacaoLens'),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.grayLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(Icons.image, size: 120, color: AppColors.gray),
                  ),
                ),
                Center(
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.white, width: 3),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: AppColors.brown,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.beige,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.search, color: AppColors.green),
                      const SizedBox(width: 8),
                      Text('Enfoca la vaina de cacao', style: AppTextStyles.body),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _CircleIcon(
                      icon: Icons.image,
                      onTap: () => _handleImageSelection(context, ImageSource.gallery),
                    ),
                    _CircleCapture(
                      // Llama a la cámara nativa
                      onTap: () => _handleImageSelection(context, ImageSource.camera),
                    ),
                    _CircleIcon(
                      icon: Icons.sync,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.brownDark,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Icon(icon, color: AppColors.white),
      ),
    );
  }
}

class _CircleCapture extends StatelessWidget {
  const _CircleCapture({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.green,
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: AppColors.white, width: 4),
        ),
        child: const Icon(Icons.camera_alt, color: AppColors.white, size: 32),
      ),
    );
  }
}
