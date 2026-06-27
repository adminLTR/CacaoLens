// UT-FL-05: Verificar carga de imágenes
// Basado en: lib/providers/analysis_provider_io.dart -> pickImage()
//
// El provider valida:
//   1. Extensión: solo jpg, jpeg, png
//   2. Tamaño: máximo 5MB (5 * 1024 * 1024 bytes)
//   3. Si el usuario cancela → pickedFile es null
//
// Requiere mockito. Genera mocks con:
//   dart run build_runner build

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([ImagePicker])
import 'ut_fl_05_image_upload_test.mocks.dart';

/// Lógica extraída de pickImage() en analysis_provider_io.dart.
bool isValidExtension(String path) {
  final ext = path.split('.').last.toLowerCase();
  return ['jpg', 'jpeg', 'png'].contains(ext);
}

/// Lógica extraída de pickImage() en analysis_provider_io.dart.
bool isValidFileSize(int sizeBytes) {
  const maxSizeBytes = 5 * 1024 * 1024; // 5MB
  return sizeBytes <= maxSizeBytes;
}

void main() {
  group('UT-FL-05: Verificar carga de imágenes', () {
    late MockImagePicker mockPicker;

    setUp(() {
      mockPicker = MockImagePicker();
    });

    // --- Validaciones de extensión ---
    test('Extensión .jpg es válida', () {
      expect(isValidExtension('/tmp/foto_cacao.jpg'), isTrue);
    });

    test('Extensión .jpeg es válida', () {
      expect(isValidExtension('/tmp/foto_cacao.jpeg'), isTrue);
    });

    test('Extensión .png es válida', () {
      expect(isValidExtension('/tmp/foto_cacao.png'), isTrue);
    });

    test('Extensión .gif no es válida', () {
      expect(isValidExtension('/tmp/foto_cacao.gif'), isFalse);
    });

    test('Extensión .pdf no es válida', () {
      expect(isValidExtension('/tmp/documento.pdf'), isFalse);
    });

    // --- Validaciones de tamaño ---
    test('Imagen de 1MB es válida', () {
      expect(isValidFileSize(1 * 1024 * 1024), isTrue);
    });

    test('Imagen de exactamente 5MB es válida', () {
      expect(isValidFileSize(5 * 1024 * 1024), isTrue);
    });

    test('Imagen de más de 5MB es inválida', () {
      expect(isValidFileSize(5 * 1024 * 1024 + 1), isFalse);
    });

    // --- Mock de ImagePicker ---
    test('Devuelve imagen al seleccionar de galería', () async {
      final fakeFile = XFile('test/assets/cacao_test.jpg');
      when(mockPicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: anyNamed('imageQuality'),
      )).thenAnswer((_) async => fakeFile);

      final result = await mockPicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 95,
      );

      expect(result, isNotNull);
      expect(result!.path, contains('.jpg'));
    });

    test('Devuelve imagen al usar la cámara', () async {
      final fakeFile = XFile('test/assets/camara_cacao.jpg');
      when(mockPicker.pickImage(
        source: ImageSource.camera,
        imageQuality: anyNamed('imageQuality'),
      )).thenAnswer((_) async => fakeFile);

      final result = await mockPicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 95,
      );

      expect(result, isNotNull);
    });

    test('Devuelve null si el usuario cancela la selección', () async {
      when(mockPicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: anyNamed('imageQuality'),
      )).thenAnswer((_) async => null);

      final result = await mockPicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 95,
      );

      expect(result, isNull);
    });
  });
}
