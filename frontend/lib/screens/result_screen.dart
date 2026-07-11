import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/analysis_result.dart';
import '../models/diagnosis.dart';
import '../models/history_item.dart';
import '../providers/history_provider.dart';
import '../providers/analysis_provider.dart';
import '../routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/flow_stepper.dart';
import '../widgets/status_pill.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isSaving = false;
  bool _isExporting = false;

  String _confidenceQualifier(double confidence) {
    final percent = confidence * 100;
    if (percent >= 85) return 'Confianza alta';
    if (percent >= 60) return 'Confianza moderada';
    return 'Confianza baja';
  }

  Future<void> _handleSave(HistoryItem item) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      await Provider.of<HistoryProvider>(context, listen: false).saveResult(item);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Resultado guardado en historial'),
          backgroundColor: AppColors.green,
          action: SnackBarAction(
            label: 'Ver historial',
            textColor: AppColors.white,
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.history),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleExport({
    required String? imagePath,
    required String label,
    required double confidence,
    required String recommendation,
  }) async {
    if (_isExporting) return;
    setState(() => _isExporting = true);

    try {
      final confianzaTexto = (confidence * 100).toStringAsFixed(1);
      final fecha = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
      final shareText = '¡Diagnóstico CacaoLens!\n'
          'Resultado: $label\n'
          'Confianza: $confianzaTexto%\n'
          'Fecha: $fecha\n\n'
          'Recomendación: $recommendation';

      if (imagePath != null && imagePath.isNotEmpty) {
        await SharePlus.instance.share(
          ShareParams(files: [XFile(imagePath)], text: shareText),
        );
      } else {
        await SharePlus.instance.share(ShareParams(text: shareText));
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AnalysisProvider>(context);
    final AnalysisResult? analysisResult = provider.analysisResult;

    final String label = analysisResult?.label ?? 'DESCONOCIDO';
    final double confianza = (analysisResult?.confidence ?? 0.0).clamp(0.0, 1.0);
    final category = DiagnosisCategoryX.fromLabel(label);

    final String? imagePath = provider.selectedImagePath;
    final String confianzaTexto = (confianza * 100).toStringAsFixed(1);

    return AppScaffold(
      showMenu: true,
      title: const Text('Resultados'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          children: [
            const FlowStepper(currentStep: 3),
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
                    child: _ResultImage(imagePath: imagePath),
                  ),
                  const SizedBox(height: 18),
                  StatusPill(label: category.displayLabel.toUpperCase(), color: category.color),
                  const SizedBox(height: 10),
                  Text(
                    '$_confidenceLabelPrefix$confianzaTexto% · ${_confidenceQualifier(confianza)}',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: confianza),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => LinearProgressIndicator(
                        value: value,
                        minHeight: 16,
                        color: category.color,
                        backgroundColor: AppColors.gray,
                      ),
                    ),
                  ),
                  if (analysisResult != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      analysisResult.fromLocalModel
                          ? 'Analizado en este dispositivo'
                          : 'Analizado en la nube',
                      style: AppTextStyles.body.copyWith(fontSize: 12, color: AppColors.grayDark),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.beige,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(category.icon, color: category.color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Recomendación', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text(category.recommendation, style: AppTextStyles.body),
                      ],
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
                    label: _isSaving ? 'Guardando...' : 'Guardar',
                    onPressed: _isSaving
                        ? null
                        : () => _handleSave(
                              HistoryItem(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                imagePath: imagePath ?? '',
                                status: label,
                                confidence: confianza,
                                date: DateTime.now(),
                              ),
                            ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton.secondary(
                    label: _isExporting ? 'Compartiendo...' : 'Exportar',
                    onPressed: _isExporting
                        ? null
                        : () => _handleExport(
                              imagePath: imagePath,
                              label: category.displayLabel,
                              confidence: confianza,
                              recommendation: category.recommendation,
                            ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static const _confidenceLabelPrefix = 'Confianza: ';
}

class _ResultImage extends StatelessWidget {
  const _ResultImage({required this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) {
      return const Center(
        child: Icon(Icons.image, size: 72, color: AppColors.grayDark),
      );
    }

    if (kIsWeb) {
      return Image.network(
        imagePath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.broken_image, size: 72, color: AppColors.grayDark),
          );
        },
      );
    }

    return Image.file(
      File(imagePath!),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Icon(Icons.broken_image, size: 72, color: AppColors.grayDark),
        );
      },
    );
  }
}
