import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/screens/welcome_screen.dart';
import '../../auth/widgets/safe_route_logo.dart';

/// Screen 2: Onboarding Screen
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _navigateToWelcome(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => _navigateToWelcome(context),
            child: const Text(
              'Skip',
              style: TextStyle(
                color: AppColors.primaryTeal,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Illustration area
              _buildIllustration(),

              const Spacer(flex: 1),

              // Page Indicator dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 22,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 6,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1E5E1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 6,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1E5E1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Title
              const Text(
                'Track Your Child\'s Journey',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),

              // Description
              const Text(
                'Follow the school bus route and see clear, time-stamped location updates throughout the journey.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),

              const Spacer(flex: 2),

              // Next Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _navigateToWelcome(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      width: 280,
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFFE4F2EE),
        borderRadius: BorderRadius.circular(140),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(140),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Road strip
            Transform.rotate(
              angle: -0.15,
              child: Container(
                width: 320,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFCFDBD7),
                  border: Border.symmetric(
                    horizontal: BorderSide(
                      color: const Color(0xFFB9CBC5),
                      width: 6,
                    ),
                  ),
                ),
              ),
            ),
            // Pin marker 1 (top left)
            const Positioned(
              top: 36,
              left: 56,
              child: Icon(
                Icons.location_on,
                color: Color(0xFFF97316),
                size: 26,
              ),
            ),
            // Pin marker 2 (bottom right)
            const Positioned(
              bottom: 42,
              right: 64,
              child: Icon(
                Icons.location_on,
                color: Color(0xFFF97316),
                size: 26,
              ),
            ),
            // Center Bus Logo
            const SafeRouteLogo(size: 64),
          ],
        ),
      ),
    );
  }
}

