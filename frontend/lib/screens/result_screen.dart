import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/analysis_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_scaffold.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showMenu: true,
      title: const Text('Resultados'),
      body: Consumer<AnalysisProvider>(
        builder: (context, provider, child) {
          
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.green),
                  SizedBox(height: 16),
                  Text("Analizando imagen...", style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          }

          String categoriaText = "Desconocido";
          double confianzaValor = 0.0;
          Color colorEstado = AppColors.grayDark;

          if (provider.result.contains('(')) {
            final partes = provider.result.split('(');
            categoriaText = partes[0].trim().toUpperCase();
            
            final numeroString = partes[1].replaceAll('%)', '');
            confianzaValor = double.tryParse(numeroString) ?? 0.0;
            
            // Asignar colores según la calidad
            if (categoriaText == 'ALTA CALIDAD') colorEstado = AppColors.green;
            else if (categoriaText == 'MEDIA CALIDAD') colorEstado = AppColors.brown;
            else if (categoriaText == 'BAJA CALIDAD') colorEstado = Colors.red;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.grayLight,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.grayDark),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: provider.selectedImage != null
                            ? Image.file(
                                provider.selectedImage!,
                                fit: BoxFit.cover,
                              )
                            : const Center(
                                child: Icon(Icons.image, size: 72, color: AppColors.grayDark),
                              ),
                      ),
                      const SizedBox(height: 18),
                      
                      Text(
                        categoriaText,
                        style: AppTextStyles.titleLarge.copyWith(color: colorEstado),
                      ),
                      const SizedBox(height: 6),

                      Text(
                        'Confianza: $confianzaValor%',
                        style: AppTextStyles.body,
                      ),
                      const SizedBox(height: 16),
                      
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: confianzaValor / 100,
                          minHeight: 14,
                          color: colorEstado,
                          backgroundColor: AppColors.gray,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: AppButton.primary(
                        label: 'Guardar',
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton.secondary(
                        label: 'Descartar',
                        onPressed: () {
                           Navigator.of(context).pop(); // Regresa a la pantalla anterior
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
