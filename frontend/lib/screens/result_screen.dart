import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_scaffold.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String? imagePath = args?['imagePath'];
    final String prediccion = args?['prediccion'] ?? 'DESCONOCIDO';
    final double confianza = args?['confianza'] ?? 0.0;
    
    final double progressValue = confianza.clamp(0.0, 1.0);
    final String confianzaTexto = (confianza * 100).toStringAsFixed(1);
    
    Color resultColor = AppColors.green;
    if (prediccion.toUpperCase().contains('Baja') || prediccion.toUpperCase().contains('Media')) {
      resultColor = Colors.redAccent;
    }

    return AppScaffold(
      showMenu: true,
      title: const Text('Resultados'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.grayLight,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.grayDark),
              ),
              child: Column(
                children: [
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: imagePath != null && !kIsWeb
                        ? Image.file(File(imagePath), fit: BoxFit.cover)
                        : const Center(
                            child: Icon(Icons.image, size: 72, color: AppColors.grayDark),
                          ),
                  ),
                  const SizedBox(height: 18),
                  
                  Text(
                    prediccion.toUpperCase(), 
                    style: AppTextStyles.titleLarge.copyWith(color: resultColor)
                  ),
                  const SizedBox(height: 6),
                  Text('Confianza: $confianzaTexto%', style: AppTextStyles.body),
                  const SizedBox(height: 16),
                  
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      minHeight: 14,
                      color: resultColor,
                      backgroundColor: AppColors.gray,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppButton.primary(
                    label: 'Guardar', 
                    onPressed: () {
                    }
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton.secondary(
                    label: 'Exportar', 
                    onPressed: () async {
                      final String shareText = '¡Diagnóstico CacaoLens!\nResultado: $prediccion\nConfianza: $confianzaTexto%';
                      
                      if (imagePath != null && !kIsWeb) {
                        await Share.shareXFiles(
                          [XFile(imagePath)],
                          text: shareText,
                        );
                      } else {
                        await Share.share(shareText);
                      }
                    }
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
