import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'providers/analysis_provider.dart';
import 'routes.dart';
import 'screens/camera_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/preview_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/recover_password_screen.dart';
import 'screens/register_screen.dart';
import 'screens/result_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AnalysisProvider()),
      ],
      child: const CacaoLensApp(),
    ),
  );
}

class CacaoLensApp extends StatelessWidget {
  const CacaoLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CacaoLens',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.recover: (context) => const RecoverPasswordScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.camera: (context) => const CameraScreen(),
        AppRoutes.preview: (context) => const PreviewScreen(),
        AppRoutes.result: (context) => const ResultScreen(),
        AppRoutes.history: (context) => const HistoryScreen(),
        AppRoutes.settings: (context) => const SettingsScreen(),
        AppRoutes.profile: (context) => const ProfileScreen(),
      },
    );
  }
}