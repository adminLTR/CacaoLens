import 'package:flutter/material.dart';

enum DiagnosisCategory { healthy, blackPod, podBorer, unknown }

extension DiagnosisCategoryX on DiagnosisCategory {
  static DiagnosisCategory fromLabel(String label) {
    final normalized = label.toUpperCase();
    if (normalized.contains('PUDRIC')) return DiagnosisCategory.blackPod;
    if (normalized.contains('BORER')) return DiagnosisCategory.podBorer;
    if (normalized.contains('SALUD')) return DiagnosisCategory.healthy;
    return DiagnosisCategory.unknown;
  }

  Color get color {
    switch (this) {
      case DiagnosisCategory.healthy:
        return const Color(0xFF6BB02E);
      case DiagnosisCategory.blackPod:
        return const Color(0xFFE53935);
      case DiagnosisCategory.podBorer:
        return const Color(0xFFF2A43A);
      case DiagnosisCategory.unknown:
        return const Color(0xFF8C8C8C);
    }
  }

  String get displayLabel {
    switch (this) {
      case DiagnosisCategory.healthy:
        return 'Saludable';
      case DiagnosisCategory.blackPod:
        return 'Pudrición Negra';
      case DiagnosisCategory.podBorer:
        return 'Pod Borer';
      case DiagnosisCategory.unknown:
        return 'Desconocido';
    }
  }

  IconData get icon {
    switch (this) {
      case DiagnosisCategory.healthy:
        return Icons.check_circle;
      case DiagnosisCategory.blackPod:
        return Icons.warning_amber_rounded;
      case DiagnosisCategory.podBorer:
        return Icons.bug_report;
      case DiagnosisCategory.unknown:
        return Icons.help_outline;
    }
  }

  String get recommendation {
    switch (this) {
      case DiagnosisCategory.healthy:
        return 'La vaina se ve saludable. Continúa con el monitoreo regular y mantén buenas '
            'prácticas de poda y ventilación en la parcela.';
      case DiagnosisCategory.blackPod:
        return 'Pudrición Negra detectada: retira y elimina los frutos afectados, evita el '
            'exceso de humedad y mejora la ventilación entre plantas para frenar el contagio.';
      case DiagnosisCategory.podBorer:
        return 'Pod Borer detectado: aísla y retira la vaina afectada, revisa las vainas '
            'cercanas y considera trampas o control biológico para reducir la plaga.';
      case DiagnosisCategory.unknown:
        return 'No se pudo determinar el estado con certeza. Intenta con otra foto, con mejor '
            'luz y enfoque, para obtener un diagnóstico más confiable.';
    }
  }
}
