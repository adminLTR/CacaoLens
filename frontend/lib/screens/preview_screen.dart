import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  String? _imagePath;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_imagePath == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        _imagePath = args;
      }
    }
  }

  Future<void> _startAnalysis() async {
    if (_imagePath == null) return;
    setState(() => _isAnalyzing = true);
    
    try {
      var request = http.MultipartRequest(
        'POST',
        // Para dispositivo físico real, usamos la IP de tu PC en la red.
        // Si no te funciona, cámbiala a 'http://10.0.2.2:8000/predict' si usas emulador.
        Uri.parse('http://10.0.2.2:8000/predict'),
      );
      
      if (kIsWeb) {
        // En Web necesitamos obtener los bytes desde la URL blob generada por image_picker
        var responseBytes = await http.get(Uri.parse(_imagePath!));
        request.files.add(
          http.MultipartFile.fromBytes('file', responseBytes.bodyBytes, filename: 'upload.jpg'),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('file', _imagePath!),
        );
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var result = json.decode(responseData);
        
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.result, 
          arguments: {
            'imagePath': _imagePath,
            'prediccion': result['prediccion'],
            'confianza': result['confianza'],
          }
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error del servidor: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
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
