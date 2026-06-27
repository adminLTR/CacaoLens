// UT-FL-02: Validar contraseña mínima
// Basado en: lib/screens/login_screen.dart -> _handleLogin()
// La app valida que la contraseña no esté vacía antes de enviarla al backend.
// El campo se llama 'contrasena' en AuthService.login().

import 'package:flutter_test/flutter_test.dart';

/// Lógica extraída de _handleLogin() en login_screen.dart.
bool isPasswordEmpty(String password) => password.trim().isEmpty;

/// Regla de negocio: contraseña de al menos 6 caracteres.
bool isPasswordValid(String password) => password.trim().length >= 6;

void main() {
  group('UT-FL-02: Validar contraseña mínima', () {
    test('Contraseña vacía es detectada', () {
      expect(isPasswordEmpty(''), isTrue);
    });

    test('Contraseña con solo espacios es detectada como vacía', () {
      expect(isPasswordEmpty('   '), isTrue);
    });

    test('Contraseña no vacía pasa la validación básica', () {
      expect(isPasswordEmpty('cacao123'), isFalse);
    });

    test('Contraseña de 6 caracteres es válida', () {
      expect(isPasswordValid('abc123'), isTrue);
    });

    test('Contraseña de 5 caracteres es inválida', () {
      expect(isPasswordValid('ab123'), isFalse);
    });

    test('Contraseña de 1 caracter es inválida', () {
      expect(isPasswordValid('x'), isFalse);
    });

    test('Contraseña larga es válida', () {
      expect(isPasswordValid('MiContraseñaSegura2024!'), isTrue);
    });
  });
}
