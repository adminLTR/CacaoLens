import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:share_plus/share_plus.dart';

import '../models/history_item.dart';
import '../providers/history_provider.dart';
import '../providers/analysis_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_scaffold.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AnalysisProvider>(context);
    final String fullResult = provider.result;
    
    String prediccion = 'DESCONOCIDO';
    double confianza = 0.0;
    
    if (fullResult.contains('(')) {
      final parts = fullResult.split('(');
      prediccion = parts[0].trim();
      final confString = parts[1].replaceAll('%)', '').trim();
      confianza = (double.tryParse(confString) ?? 0.0) / 100.0;
    } else {
      prediccion = fullResult; 
    }

    final String? imagePath = !kIsWeb && provider.selectedImage != null 
        ? (provider.selectedImage as dynamic).path 
        : null;

    final double progressValue = confianza.clamp(0.0, 1.0);
    final String confianzaTexto = (confianza * 100).toStringAsFixed(1);
    
    Color resultColor = AppColors.green;
    final normalizedPrediction = prediccion.toUpperCase();
    if (normalizedPrediction.contains('PUDRIC') || normalizedPrediction.contains('BORER')) {
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
                    child: imagePath != null
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
                      final historyItem = HistoryItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        imagePath: imagePath ?? '',
                        status: prediccion,
                        confidence: confianza,
                        date: DateTime.now(),
                      );
                      Provider.of<HistoryProvider>(context, listen: false).saveResult(historyItem);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('¡Análisis guardado en el historial!'),
                            backgroundColor: AppColors.green,
                          ),
                        );
                      }
                    }
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton.secondary(
                    label: 'Exportar', 
                    onPressed: () async {
                      final String shareText = '¡Diagnóstico CacaoLens!\nResultado: $prediccion\nConfianza: $confianzaTexto%';
                      
                      if (imagePath != null) {
                        await SharePlus.instance.share(
                          ShareParams(
                            files: [XFile(imagePath)],
                            text: shareText,
                          ),
                        );
                      } else {
                        await SharePlus.instance.share(
                          ShareParams(text: shareText),
                        );
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
