import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/analysis_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalysisProvider>(context, listen: false).fetchAnalysisHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Análisis'),
        centerTitle: true,
      ),
      body: Consumer<AnalysisProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchAnalysisHistory(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (provider.analysisHistory.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay análisis previos',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchAnalysisHistory(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: provider.analysisHistory.length,
              itemBuilder: (context, index) {
                final analysis = provider.analysisHistory[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.analytics,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      analysis['prediction'] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Confianza: ${((analysis['confidence'] ?? 0.0) * 100).toStringAsFixed(1)}%',
                    ),
                    trailing: Text(
                      analysis['createdAt'] ?? '',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    onTap: () {
                      // Navigate to detail or show dialog
                      _showAnalysisDetail(context, analysis);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showAnalysisDetail(BuildContext context, Map<String, dynamic> analysis) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalles del Análisis'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Predicción: ${analysis['prediction']}'),
            const SizedBox(height: 8),
            Text('Confianza: ${((analysis['confidence'] ?? 0.0) * 100).toStringAsFixed(1)}%'),
            const SizedBox(height: 8),
            Text('Fecha: ${analysis['createdAt']}'),
            const SizedBox(height: 8),
            Text('ID: ${analysis['id']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
