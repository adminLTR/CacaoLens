enum AnalysisStage { idle, uploading, analyzing, generatingResult, done, error }

class AnalysisResult {
  const AnalysisResult({
    required this.label,
    required this.confidence,
    required this.fromLocalModel,
  });

  final String label;
  final double confidence;
  final bool fromLocalModel;
}
