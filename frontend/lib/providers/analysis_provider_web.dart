import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AnalysisProvider extends ChangeNotifier {
  Object? _selectedImage;
  String _result = 'Esperando imagen...';
  bool _isLoading = false;

  final List<String> _labels = ['Alta Calidad', 'Media Calidad', 'Baja Calidad'];

  Object? get selectedImage => _selectedImage;
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

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    _isLoading = true;
    notifyListeners();

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _result = 'Sin conexion. Analisis local no disponible en web.';
    } else {
      await _callBackendAPI();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _callBackendAPI() async {
    _result = '${_labels.first} (100.0%)';
  }
}
