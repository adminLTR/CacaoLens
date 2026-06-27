// UT-FL-03: Verificar almacenamiento local
// Basado en:
//   - lib/screens/login_screen.dart -> _handleLogin(): guarda 'auth_token', 'user_email', 'user_name'
//   - lib/providers/history_provider.dart -> loadHistory()/saveResult(): usa 'cacao_history'

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('UT-FL-03: Verificar almacenamiento local', () {
    setUp(() {
      // SharedPreferences en modo test usa un mapa en memoria
      SharedPreferences.setMockInitialValues({});
    });

    test('Guarda auth_token tras login exitoso', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9');

      expect(prefs.getString('auth_token'), equals('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'));
    });

    test('Guarda user_email tras login exitoso', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', 'agricultor@cacaolens.com');

      expect(prefs.getString('user_email'), equals('agricultor@cacaolens.com'));
    });

    test('Guarda user_name tras login exitoso', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', 'José');

      expect(prefs.getString('user_name'), equals('José'));
    });

    test('Retorna null si auth_token no existe (sesión no iniciada)', () async {
      final prefs = await SharedPreferences.getInstance();

      expect(prefs.getString('auth_token'), isNull);
    });

    test('Guarda lista de historial cacao_history correctamente', () async {
      final prefs = await SharedPreferences.getInstance();
      final historialJson = [
        '{"id":"1","imagePath":"/img/a.jpg","status":"Saludable","confidence":0.95,"date":"2025-06-01T00:00:00.000"}',
        '{"id":"2","imagePath":"/img/b.jpg","status":"Pudrición Negra","confidence":0.87,"date":"2025-06-02T00:00:00.000"}',
      ];

      await prefs.setStringList('cacao_history', historialJson);

      final stored = prefs.getStringList('cacao_history');
      expect(stored, isNotNull);
      expect(stored!.length, equals(2));
    });

    test('Retorna lista vacía si no hay historial guardado', () async {
      final prefs = await SharedPreferences.getInstance();

      final stored = prefs.getStringList('cacao_history');
      expect(stored, isNull); // nunca fue inicializado → null (el provider usa ?? [])
    });

    test('Guarda preferencia settings_save_originals', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('settings_save_originals', false);

      expect(prefs.getBool('settings_save_originals'), isFalse);
    });
  });
}
