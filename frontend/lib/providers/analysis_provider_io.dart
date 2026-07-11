import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../config/api_config.dart';
import '../models/analysis_result.dart';

class AnalysisProvider extends ChangeNotifier {
  File? _selectedImage;
  String _result = 'Esperando imagen...';
  bool _isLoading = false;
  Interpreter? _interpreter;
  AnalysisStage _stage = AnalysisStage.idle;
  AnalysisResult? _analysisResult;

  final List<String> _labels = ['Saludable', 'Pudrición Negra', 'Pod Borer'];

  File? get selectedImage => _selectedImage;
  String? get selectedImagePath => _selectedImage?.path;
  String get result => _result;
  bool get isLoading => _isLoading;
  AnalysisStage get stage => _stage;
  AnalysisResult? get analysisResult => _analysisResult;
  bool get isLocalModelReady => _interpreter != null;

  AnalysisProvider() {
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/Cacao_InceptionV3_best.tflite');
      debugPrint('Modelo TFLite cargado correctamente');
      notifyListeners();
    } catch (e) {
      debugPrint('Modelo TFLite local no disponible: $e');
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final prefs = await SharedPreferences.getInstance();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: _imageQualityFromSetting(
        prefs.getString('settings_image_quality'),
      ),
    );

    if (pickedFile != null) {
      final fileExtension = pickedFile.path.split('.').last.toLowerCase();
      final validExtensions = ['jpg', 'jpeg', 'png'];

      if (!validExtensions.contains(fileExtension)) {
        _result = 'Error: Solo se permiten imágenes JPG o PNG';
        _selectedImage = null;
        notifyListeners();
        return;
      }

      final fileSize = await pickedFile.length();
      const maxSizeBytes = 5 * 1024 * 1024;

      if (fileSize > maxSizeBytes) {
        _result = 'Error: La imagen es muy pesada (Máximo 5MB)';
        _selectedImage = null;
        notifyListeners();
        return;
      }

      _selectedImage = File(pickedFile.path);
      _result = 'Analizando...';
      notifyListeners();

      await _analyzeImage();
    }
  }

  Future<void> analyzeImagePath(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      _result = 'Error: No se encontró la imagen';
      _selectedImage = null;
      notifyListeners();
      return;
    }

    _selectedImage = file;
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
      debugPrint('Modo offline detectado. Usando modelo embebido...');
      await _runLocalInference();
    } else {
      debugPrint('Conexion detectada. Enviando a la API...');
      await _callBackendAPI();
    }

    _stage = _analysisResult != null ? AnalysisStage.done : AnalysisStage.error;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _runLocalInference() async {
    if (_interpreter == null) {
      _result = 'Error: Modelo no disponible';
      return;
    }

    try {
      final imageBytes = await _selectedImage!.readAsBytes();
      _stage = AnalysisStage.analyzing;
      notifyListeners();

      final originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        _result = 'Error al decodificar la imagen';
        return;
      }

      final resizedImage = img.copyResize(originalImage, width: 224, height: 224);
      final input = _imageToMatrix(resizedImage, 224);
      final output = List.generate(1, (index) => List.filled(3, 0.0));
      _interpreter!.run(input, output);

      final probabilities = output[0];
      var highestProbIndex = 0;
      var highestProb = probabilities[0];

      for (var i = 1; i < probabilities.length; i++) {
        if (probabilities[i] > highestProb) {
          highestProb = probabilities[i];
          highestProbIndex = i;
        }
      }

      _stage = AnalysisStage.generatingResult;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 400));

      final label = _labels[highestProbIndex];
      _analysisResult = AnalysisResult(
        label: label,
        confidence: highestProb.toDouble(),
        fromLocalModel: true,
      );
      _result = '$label (${(highestProb * 100).toStringAsFixed(1)}%)';
    } catch (e) {
      debugPrint('Error en inferencia: $e');
      _result = 'Error al analizar imagen localmente';
    }
  }

  List _imageToMatrix(img.Image image, int inputSize) {
    final matrix = List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (y) => List.generate(
          inputSize,
          (x) => List.filled(3, 0.0),
        ),
      ),
    );

    for (var y = 0; y < inputSize; y++) {
      for (var x = 0; x < inputSize; x++) {
        final pixel = image.getPixel(x, y);
        matrix[0][y][x][0] = pixel.r / 255.0;
        matrix[0][y][x][1] = pixel.g / 255.0;
        matrix[0][y][x][2] = pixel.b / 255.0;
      }
    }
    return matrix;
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
        await http.MultipartFile.fromPath('image', _selectedImage!.path),
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

  int _imageQualityFromSetting(String? value) {
    switch (value) {
      case 'Baja':
        return 55;
      case 'Media':
        return 75;
      case 'Alta':
      default:
        return 95;
    }
  }
}
