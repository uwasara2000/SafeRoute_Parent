import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/tracking/screens/live_tracking_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase using the generated configuration
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ParentTrackingApp());
}

class ParentTrackingApp extends StatelessWidget {
  const ParentTrackingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parent Bus Tracking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const LiveTrackingScreen(tripId: 'trip_001'),
    );
  }
}
