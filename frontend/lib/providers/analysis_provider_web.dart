import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/analysis_result.dart';

class AnalysisProvider extends ChangeNotifier {
  XFile? _selectedImage;
  String _result = 'Esperando imagen...';
  bool _isLoading = false;
  AnalysisStage _stage = AnalysisStage.idle;
  AnalysisResult? _analysisResult;

  XFile? get selectedImage => _selectedImage;
  String? get selectedImagePath => _selectedImage?.path;
  String get result => _result;
  bool get isLoading => _isLoading;
  AnalysisStage get stage => _stage;
  AnalysisResult? get analysisResult => _analysisResult;
  bool get isLocalModelReady => false;

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      _selectedImage = pickedFile;
      _result = 'Analizando...';
      notifyListeners();

      await _analyzeImage();
    }
  }

  Future<void> analyzeImagePath(String imagePath) async {
    _selectedImage = XFile(imagePath);
    _result = 'Analizando...';
    notifyListeners();

    await _analyzeImage();
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    _isLoading = true;
    _analysisResult = null;
    _stage = AnalysisStage.uploading;
    notifyListeners();

    final connectivityResult = await Connectivity().checkConnectivity();
    final prefs = await SharedPreferences.getInstance();
    final strictOffline = prefs.getBool('settings_offline_mode') ?? false;

    if (strictOffline || _isOffline(connectivityResult)) {
      _result = 'Sin conexion. Analisis local no disponible en web.';
    } else {
      await _callBackendAPI();
    }

    _stage = _analysisResult != null ? AnalysisStage.done : AnalysisStage.error;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _callBackendAPI() async {
    try {
      final baseUrl = ApiConfig.baseUrl;
      final uri = Uri.parse('$baseUrl/analysis/image');
      final request = http.MultipartRequest('POST', uri);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          await _selectedImage!.readAsBytes(),
          filename: _selectedImage!.name.isNotEmpty ? _selectedImage!.name : 'cacao.jpg',
        ),
      );

      _stage = AnalysisStage.analyzing;
      notifyListeners();

      final response = await request.send();
      final body = await response.stream.bytesToString();
      final payload = body.trim().isEmpty ? <String, dynamic>{} : jsonDecode(body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        _result = payload['error']?.toString() ?? 'Error del servidor (${response.statusCode})';
        return;
      }

      final prediction = (payload['prediction'] as Map?)?.cast<String, dynamic>() ?? payload;
      final label = prediction['estado']?.toString() ??
          prediction['prediccion']?.toString() ??
          'Resultado desconocido';
      final confidence = _readConfidence(prediction);

      _stage = AnalysisStage.generatingResult;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 400));

      _analysisResult = AnalysisResult(
        label: label,
        confidence: confidence,
        fromLocalModel: false,
      );
      _result = '$label (${(confidence * 100).toStringAsFixed(1)}%)';
    } catch (e) {
      debugPrint('Error al llamar API: $e');
      _result = 'Error al analizar imagen en linea';
    }
  }

  bool _isOffline(Object connectivityResult) {
    if (connectivityResult is List<ConnectivityResult>) {
      return connectivityResult.contains(ConnectivityResult.none);
    }

    return connectivityResult == ConnectivityResult.none;
  }

  double _readConfidence(Map<String, dynamic> prediction) {
    final raw = prediction['confiabilidad'] ?? prediction['confianza'] ?? 0;
    final value = raw is num ? raw.toDouble() : double.tryParse(raw.toString()) ?? 0.0;
    return value > 1 ? value / 100 : value;
  }
}
