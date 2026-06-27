// UT-FL-04: Verificar detección de conexión
// Basado en: lib/providers/analysis_provider_io.dart -> _analyzeImage() y _isOffline()
//
// connectivity_plus ^7.x retorna Future<List<ConnectivityResult>>
//
// Genera mocks con: dart run build_runner build

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([Connectivity])
import 'ut_fl_04_connectivity_test.mocks.dart';

/// Replica exacta del método privado _isOffline() de AnalysisProvider.
bool isOffline(Object connectivityResult) {
  if (connectivityResult is List<ConnectivityResult>) {
    return connectivityResult.contains(ConnectivityResult.none);
  }
  return connectivityResult == ConnectivityResult.none;
}

void main() {
  group('UT-FL-04: Verificar detección de conexión', () {
    late MockConnectivity mockConnectivity;

    setUp(() {
      mockConnectivity = MockConnectivity();
    });

    test('Sin conexión es detectada correctamente', () async {
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);

      final result = await mockConnectivity.checkConnectivity();
      expect(isOffline(result), isTrue);
    });

    test('Conexión WiFi es detectada como online', () async {
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);

      final result = await mockConnectivity.checkConnectivity();
      expect(isOffline(result), isFalse);
    });

    test('Conexión móvil es detectada como online', () async {
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.mobile]);

      final result = await mockConnectivity.checkConnectivity();
      expect(isOffline(result), isFalse);
    });

    test('Lista con ConnectivityResult.none es offline', () {
      expect(isOffline([ConnectivityResult.none]), isTrue);
    });

    test('Lista con WiFi no es offline', () {
      expect(isOffline([ConnectivityResult.wifi]), isFalse);
    });

    test('checkConnectivity es llamado exactamente una vez', () async {
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);

      await mockConnectivity.checkConnectivity();
      verify(mockConnectivity.checkConnectivity()).called(1);
    });
  });
}
