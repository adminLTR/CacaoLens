import 'package:flutter/material.dart';

import '../routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_scaffold.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  bool _isAnalyzing = false;

  Future<void> _startAnalysis() async {
    setState(() => _isAnalyzing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isAnalyzing = false);
    Navigator.of(context).pushReplacementNamed(AppRoutes.result);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showMenu: true,
      title: const Text('Vista Previa'),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              children: [
                Container(
                  height: 320,
                  decoration: BoxDecoration(
                    color: AppColors.grayLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.gray),
                  ),
                  child: const Center(
                    child: Icon(Icons.image, size: 120, color: AppColors.grayDark),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: AppButton.primary(
                        label: 'Analizar',
                        onPressed: _startAnalysis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton.danger(
                        label: 'Descartar',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isAnalyzing)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.white),
                    const SizedBox(height: 12),
                    Text('Analizando vaina de cacao...', style: AppTextStyles.body.copyWith(color: AppColors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
