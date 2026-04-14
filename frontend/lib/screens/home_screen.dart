import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/analysis_provider.dart';
import '../widgets/custom_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    final analysisProvider = Provider.of<AnalysisProvider>(context, listen: false);
    
    try {
      await analysisProvider.analyzeImage(_selectedImage!);
      
      if (analysisProvider.error == null) {
        Navigator.pushNamed(context, '/analysis');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(analysisProvider.error!)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CacaoLens'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/history'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo or Header
              const Icon(
                Icons.camera_alt,
                size: 100,
                color: Color(0xFF6B4423),
              ),
              const SizedBox(height: 20),
              const Text(
                'Analiza tu Cacao',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Toma o selecciona una foto de cacao para comenzar el análisis',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              
              // Image Preview
              if (_selectedImage != null)
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: FileImage(_selectedImage!),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[200],
                  ),
                  child: const Icon(
                    Icons.add_photo_alternate,
                    size: 80,
                    color: Colors.grey,
                  ),
                ),
              
              const SizedBox(height: 30),
              
              // Buttons
              CustomButton(
                text: 'Tomar Foto',
                icon: Icons.camera,
                onPressed: () => _pickImage(ImageSource.camera),
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Seleccionar de Galería',
                icon: Icons.photo_library,
                onPressed: () => _pickImage(ImageSource.gallery),
                isPrimary: false,
              ),
              
              if (_selectedImage != null) ...[
                const SizedBox(height: 20),
                Consumer<AnalysisProvider>(
                  builder: (context, provider, child) {
                    return CustomButton(
                      text: 'Analizar',
                      icon: Icons.analytics,
                      onPressed: provider.isLoading ? null : _analyzeImage,
                      isLoading: provider.isLoading,
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
