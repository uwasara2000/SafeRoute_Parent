import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Reusable brand logo icon for SafeRoute (Teal rounded container with bus icon)
class SafeRouteLogo extends StatelessWidget {
  final double size;

  const SafeRouteLogo({super.key, this.size = 76.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryTeal,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.directions_bus_rounded,
          color: Colors.white,
          size: size * 0.52,
        ),
      ),
    );
  }
}
