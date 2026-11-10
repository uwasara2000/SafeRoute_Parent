import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'core/constants/app_colors.dart';
import 'features/home/screens/home_screen.dart';
import 'features/onboarding/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Object? initializationError;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error) {
    initializationError = error;
  }
  runApp(SafeRouteApp(initializationError: initializationError));
}

/// Root widget for the SafeRoute (Track My Kid) application
class SafeRouteApp extends StatelessWidget {
  final Object? initializationError;

  const SafeRouteApp({super.key, this.initializationError});

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
      home: initializationError == null
          ? const _AuthenticationGate()
          : const _FirebaseInitializationErrorScreen(),
    );
  }
}

class _AuthenticationGate extends StatelessWidget {
  const _AuthenticationGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _FirebaseInitializationErrorScreen();
        }
        if (snapshot.connectionState == ConnectionState.waiting &&
            snapshot.data == null) {
          return const SplashScreen();
        }
        return snapshot.data == null
            ? const SplashScreen()
            : const HomeScreen();
      },
    );
  }
}

class _FirebaseInitializationErrorScreen extends StatelessWidget {
  const _FirebaseInitializationErrorScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off_outlined, size: 48),
                SizedBox(height: 16),
                Text(
                  'SafeRoute could not connect to its account services.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Check the Firebase configuration and restart the app.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
