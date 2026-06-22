import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl {
    const definedUrl = String.fromEnvironment('API_BASE_URL');
    final configured = definedUrl.trim().isNotEmpty
        ? definedUrl.trim()
        : dotenv.env['API_BASE_URL']?.trim();
    final rawUrl = (configured != null && configured.isNotEmpty)
        ? configured
        : 'http://localhost:3000/api';

    if (!Platform.isAndroid) {
      return rawUrl;
    }

    const useAndroidEmulatorHost = bool.fromEnvironment(
      'USE_ANDROID_EMULATOR_HOST',
    );
    if (!useAndroidEmulatorHost) {
      return rawUrl;
    }

    final uri = Uri.tryParse(rawUrl);
    if (uri == null) {
      return rawUrl;
    }

    if (uri.host == 'localhost' || uri.host == '127.0.0.1') {
      return uri.replace(host: '10.0.2.2').toString();
    }

    return rawUrl;
  }
}
