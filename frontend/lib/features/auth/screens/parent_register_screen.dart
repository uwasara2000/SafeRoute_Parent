import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../home/screens/home_screen.dart';
import '../services/auth_service.dart';
import '../widgets/registration_form.dart';

/// Screen representing the Parent Registration UI for SafeRoute
class ParentRegisterScreen extends StatefulWidget {
  const ParentRegisterScreen({super.key});

  @override
  State<ParentRegisterScreen> createState() => _ParentRegisterScreenState();
}

class _ParentRegisterScreenState extends State<ParentRegisterScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleRegistration({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _authService.registerParent(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );

      if (!mounted) return;

      if (response.isSuccess) {
        // Show success confirmation
        _showSuccessDialog(response.user?.fullName ?? fullName);
      } else {
        _showErrorSnackBar(
          response.errorMessage ??
              'Registration failed. Please check your details.',
        );
      }
    } catch (_) {
      if (!mounted) return;
      _showErrorSnackBar('An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog(String name) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: AppColors.primaryTeal, size: 28),
            SizedBox(width: 10),
            Text(
              'Account Created',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $name!',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your parent registration is submitted. Your child will be linked to the school bus route once operator verification is complete.',
              style: TextStyle(
                fontSize: 13.5,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(
                  builder: (_) => HomeScreen(parentName: name),
                ),
                (_) => false,
              );
            },
            child: const Text('Continue to SafeRoute'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 13.5),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            // In standalone/initial test mode, show feedback if back stack is empty
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Back button tapped (Navigation root reached)'),
                  duration: Duration(seconds: 1),
                ),
              );
            }
          },
        ),
        title: const Text(
          'Create Account',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Page Header
              const Text(
                'Parent registration',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your child is linked only after operator verification.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 28),

              // Form Component
              RegistrationForm(
                isLoading: _isLoading,
                onSubmit: _handleRegistration,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
