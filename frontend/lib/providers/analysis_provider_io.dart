import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class AnalysisProvider extends ChangeNotifier {
  File? _selectedImage;
  String _result = 'Esperando imagen...';
  bool _isLoading = false;
  Interpreter? _interpreter;

  final List<String> _labels = ['Alta Calidad', 'Media Calidad', 'Baja Calidad'];

  File? get selectedImage => _selectedImage;
  String get result => _result;
  bool get isLoading => _isLoading;

  AnalysisProvider() {
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/Cacao_InceptionV3_best.tflite');
      debugPrint('Modelo TFLite cargado correctamente');
    } catch (e) {
      debugPrint('Error al cargar el modelo: $e');
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

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
      final maxSizeBytes = 5 * 1024 * 1024; 

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

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    _isLoading = true;
    notifyListeners();

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      debugPrint('Modo offline detectado. Usando modelo embebido...');
      await _runLocalInference();
    } else {
      debugPrint('Conexion detectada. Enviando a la API...');
      await _callBackendAPI();
    }

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

      _result = '${_labels[highestProbIndex]} (${(highestProb * 100).toStringAsFixed(1)}%)';
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
    _result = 'Analisis Web: En construccion';
  }
}
