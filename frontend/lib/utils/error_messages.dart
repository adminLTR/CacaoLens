import 'dart:async';
import 'dart:io';

String friendlyMessage(Object error) {
  if (error is SocketException || error is HttpException) {
    return 'No pudimos analizar la imagen. Revisa tu conexión e inténtalo nuevamente.';
  }

  if (error is TimeoutException) {
    return 'El servidor tardó demasiado en responder. Inténtalo de nuevo en unos segundos.';
  }

  final text = error.toString().replaceFirst('Exception: ', '');
  final lower = text.toLowerCase();

  if (lower.contains('socketexception') ||
      lower.contains('failed host lookup') ||
      lower.contains('connection refused') ||
      lower.contains('network')) {
    return 'No pudimos conectarnos al servidor. Revisa tu conexión e inténtalo nuevamente.';
  }

  if (lower.contains('timeout')) {
    return 'El servidor tardó demasiado en responder. Inténtalo de nuevo en unos segundos.';
  }

  if (text.trim().isEmpty) {
    return 'Ocurrió un problema inesperado. Inténtalo nuevamente.';
  }

  return text;
}
