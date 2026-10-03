import 'dart:async';
import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PlantPulseColors.forest,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              right: -70,
              top: -80,
              child: _Glow(size: 230),
            ),
            Positioned(
              left: -100,
              bottom: -100,
              child: _Glow(size: 270),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .25),
                      ),
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'PlantPulse',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI crop health, made simple',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .72),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 44),
                  SizedBox(
                    width: 130,
                    child: LinearProgressIndicator(
                      minHeight: 4,
                      backgroundColor: Colors.white.withValues(alpha: .15),
                      color: PlantPulseColors.bright,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Loading diagnostic model',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .55),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Center(
                child: Text(
                  'ON-DEVICE • PRIVATE • PLANT HEALTH',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final double size;

  const _Glow({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: PlantPulseColors.bright.withValues(alpha: .12),
      ),
    );
  }
}
