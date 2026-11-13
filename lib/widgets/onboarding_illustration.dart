import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Memakai gambar asli kalau file asset ada, selain itu placeholder.
class OnboardingIllustration extends StatelessWidget {
  const OnboardingIllustration({
    super.key,
    required this.asset,
    required this.icon,
    this.height = 280,
  });

  final String asset;
  final IconData icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F6FA),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(icon, size: 96, color: AppColors.primary),
      ),
    );
  }
}