// UT-FL-01: Validar email correcto
// Basado en: lib/screens/login_screen.dart -> _handleLogin()
// La app valida que el email no esté vacío antes de llamar a AuthService.login()

import 'package:flutter_test/flutter_test.dart';

/// Lógica extraída de _handleLogin() en login_screen.dart.
/// El campo 'correo' se envía al backend como campo requerido.
bool isEmailEmpty(String email) => email.trim().isEmpty;

/// Validación de formato de email (complementaria al backend).
bool isValidEmailFormat(String email) {
  final regex = RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w{2,}$');
  return regex.hasMatch(email.trim());
}

void main() {
  group('UT-FL-01: Validar email correcto', () {
    test('Email válido no está vacío', () {
      const email = 'usuario@ejemplo.com';
      expect(isEmailEmpty(email), isFalse);
    });

    test('Email vacío es detectado', () {
      const email = '';
      expect(isEmailEmpty(email), isTrue);
    });

    test('Email con solo espacios es detectado como vacío', () {
      const email = '   ';
      expect(isEmailEmpty(email), isTrue);
    });

    test('Email con formato correcto pasa validación', () {
      expect(isValidEmailFormat('agricultor@cacaolens.com'), isTrue);
    });

    test('Email sin @ no pasa validación de formato', () {
      expect(isValidEmailFormat('agricultorcacaolens.com'), isFalse);
    });

    test('Email sin dominio no pasa validación', () {
      expect(isValidEmailFormat('agricultor@'), isFalse);
    });

    test('Email con subdominio es válido', () {
      expect(isValidEmailFormat('user@mail.cacaolens.pe'), isTrue);
    });
  });
}
