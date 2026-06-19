import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnalysisProvider extends ChangeNotifier {
  XFile? _selectedImage;
  String _result = 'Esperando imagen...';
  bool _isLoading = false;

  XFile? get selectedImage => _selectedImage;
  String get result => _result;
  bool get isLoading => _isLoading;

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
    notifyListeners();

    final connectivityResult = await Connectivity().checkConnectivity();
    if (_isOffline(connectivityResult)) {
      _result = 'Sin conexion. Analisis local no disponible en web.';
    } else {
      await _callBackendAPI();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _callBackendAPI() async {
    try {
      final baseUrl = _apiBaseUrl;
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

      _result = '$label (${(confidence * 100).toStringAsFixed(1)}%)';
    } catch (e) {
      debugPrint('Error al llamar API: $e');
      _result = 'Error al analizar imagen en linea';
    }
  }

  String get _apiBaseUrl {
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.trim().isNotEmpty) {
      return envUrl.trim();
    }

    return 'http://localhost:3000/api';
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
