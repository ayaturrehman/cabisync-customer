import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.black,
                borderRadius: BorderRadius.circular(AppBorderRadius.xl),
              ),
              child: const Icon(
                Icons.local_taxi,
                size: 64,
                color: AppColors.white,
              ),
            )
                .animate()
                .fadeIn(duration: AppAnimations.medium)
                .scale(
                  duration: AppAnimations.medium,
                  curve: AppAnimations.defaultCurve,
                ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'CabiSync',
              style: AppTextStyles.heading1,
            )
                .animate()
                .fadeIn(
                  delay: 300.ms,
                  duration: AppAnimations.medium,
                )
                .slideY(
                  begin: 0.3,
                  end: 0,
                  duration: AppAnimations.medium,
                  curve: AppAnimations.defaultCurve,
                ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your ride, simplified',
              style: AppTextStyles.bodySecondary,
            )
                .animate()
                .fadeIn(
                  delay: 600.ms,
                  duration: AppAnimations.medium,
                ),
          ],
        ),
      ),
    );
  }
}
