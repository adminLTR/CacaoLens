import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl {
    final configured = dotenv.env['API_BASE_URL']?.trim();
    if (configured != null && configured.isNotEmpty) {
      return configured;
    }

    return 'http://localhost:3000/api';
  }
}
