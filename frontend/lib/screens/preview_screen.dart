import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/analysis_provider.dart';
import '../routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/error_messages.dart';
import '../widgets/analysis_progress_steps.dart';
import '../widgets/app_button.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/flow_stepper.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  bool _isAnalyzing = false;
  String? _imagePath;
  String? _connectivityBadge;
  bool _localModelWarning = false;
  bool _didLoadBadge = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_imagePath == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        _imagePath = args;
      }
    }

    if (!_didLoadBadge) {
      _didLoadBadge = true;
      _loadConnectivityBadge();
    }
  }

  Future<void> _loadConnectivityBadge() async {
    final prefs = await SharedPreferences.getInstance();
    final strictOffline = prefs.getBool('settings_offline_mode') ?? false;
    final connectivityResult = await Connectivity().checkConnectivity();
    final offline = strictOffline || _isOffline(connectivityResult);

    if (!mounted) return;

    final analysisProvider = context.read<AnalysisProvider>();
    setState(() {
      _connectivityBadge = offline
          ? 'Se analizará en este dispositivo (sin conexión)'
          : 'Se analizará en la nube';
      _localModelWarning = offline && !analysisProvider.isLocalModelReady;
    });
  }

  bool _isOffline(Object connectivityResult) {
    if (connectivityResult is List<ConnectivityResult>) {
      return connectivityResult.contains(ConnectivityResult.none);
    }
    return connectivityResult == ConnectivityResult.none;
  }

  Future<void> _startAnalysis() async {
    if (_imagePath == null || _isAnalyzing) return;
    setState(() => _isAnalyzing = true);

    try {
      await context.read<AnalysisProvider>().analyzeImagePath(_imagePath!);

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stage = context.watch<AnalysisProvider>().stage;

    return AppScaffold(
      showMenu: true,
      title: const Text('Vista Previa'),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              children: [
                const FlowStepper(currentStep: 2),
                Container(
                  height: 320,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.grayLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.gray),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(19),
                    child: _imagePath != null
                        ? (kIsWeb
                            ? Image.network(_imagePath!, fit: BoxFit.cover)
                            : Image.file(File(_imagePath!), fit: BoxFit.cover))
                        : const Center(
                            child: Icon(Icons.image, size: 120, color: AppColors.grayDark),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_connectivityBadge != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.beige,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _connectivityBadge!.contains('nube') ? Icons.cloud : Icons.cloud_off,
                          color: AppColors.brown,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_connectivityBadge!, style: AppTextStyles.body),
                        ),
                      ],
                    ),
                  ),
                if (_localModelWarning) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3CD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Color(0xFF8A6D00), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'El modelo local no está disponible. El análisis offline podría fallar.',
                            style: AppTextStyles.body.copyWith(color: const Color(0xFF6B5300)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: AppButton.primary(
                        label: 'Analizar',
                        onPressed: _isAnalyzing ? null : _startAnalysis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton.danger(
                        label: 'Descartar',
                        onPressed: _isAnalyzing ? null : () => Navigator.of(context).pop(),
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
                child: AnalysisProgressSteps(stage: stage),
              ),
            ),
        ],
      ),
    );
  }
}
