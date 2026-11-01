import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/constants/app_colors.dart';
import 'firebase_options.dart';
import 'features/onboarding/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase.initializeApp() note: $e');
  }
  runApp(const SafeRouteApp());
}

/// Root widget for the SafeRoute (Track My Kid) application
class SafeRouteApp extends StatelessWidget {
  const SafeRouteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeRoute',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryTeal,
          primary: AppColors.primaryTeal,
          surface: AppColors.background,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
