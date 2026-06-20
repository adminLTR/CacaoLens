import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class AuthService {
  static String get _baseUrl => ApiConfig.baseUrl;

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/login');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'correo': email,
        'contrasena': password,
      }),
    );

    final payload = _decodeJson(response.body);
    if (response.statusCode != 200) {
      final message = payload['error']?.toString() ?? 'Error de inicio de sesion';
      throw Exception(message);
    }

    return payload;
  }

  static Future<Map<String, dynamic>> register({
    required String nombre,
    required String apellidos,
    required String fechaNac,
    required String dni,
    required String correo,
    required String contrasena,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/register');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'apellidos': apellidos,
        'fechaNac': fechaNac,
        'DNI': dni,
        'correo': correo,
        'contrasena': contrasena,
      }),
    );

    final payload = _decodeJson(response.body);
    if (response.statusCode != 201) {
      final message = payload['error']?.toString() ?? 'Error al registrar';
      throw Exception(message);
    }

    return payload;
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String token,
    String? nombre,
    String? apellidos,
    String? fechaNac,
    String? correo,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/profile');
    final payloadBody = <String, dynamic>{};

    if (nombre != null && nombre.trim().isNotEmpty) {
      payloadBody['nombre'] = nombre.trim();
    }
    if (apellidos != null && apellidos.trim().isNotEmpty) {
      payloadBody['apellidos'] = apellidos.trim();
    }
    if (fechaNac != null && fechaNac.trim().isNotEmpty) {
      payloadBody['fechaNac'] = fechaNac.trim();
    }
    if (correo != null && correo.trim().isNotEmpty) {
      payloadBody['correo'] = correo.trim();
    }

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payloadBody),
    );

    final payload = _decodeJson(response.body);
    if (response.statusCode != 200) {
      final message = payload['error']?.toString() ?? 'Error al actualizar perfil';
      throw Exception(message);
    }

    return payload;
  }

  static Future<void> logout({required String token}) async {
    final uri = Uri.parse('$_baseUrl/auth/logout');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final payload = _decodeJson(response.body);
      final message = payload['error']?.toString() ?? 'Error al cerrar sesion';
      throw Exception(message);
    }
  }

  static Map<String, dynamic> _decodeJson(String body) {
    if (body.trim().isEmpty) {
      return {};
    }

    return jsonDecode(body) as Map<String, dynamic>;
  }
}
