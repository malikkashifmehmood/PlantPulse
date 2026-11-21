import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_screen.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.auth});

  final FirebaseAuth? auth;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> _navigateAfterLoading() async {
    await Future<void>.delayed(const Duration(milliseconds: 1400));

    try {
      final auth = widget.auth ?? FirebaseAuth.instance;
      final user = await auth.authStateChanges().first;

      if (!mounted) return;

      final destination =
          user != null ? const HomeScreen() : const OnboardingScreen();

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute<void>(builder: (_) => destination));
    } catch (_) {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _navigateAfterLoading();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: PlantPulseColors.forest,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(right: -70, top: -80, child: _Glow(size: 230)),
            Positioned(left: -100, bottom: -100, child: _Glow(size: 270)),
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 28,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 440),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 86,
                                  height: 86,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: .12),
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: .25,
                                      ),
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
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  strings.splashSubtitle,
                                  textAlign: TextAlign.center,
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
                                    backgroundColor: Colors.white.withValues(
                                      alpha: .15,
                                    ),
                                    color: PlantPulseColors.bright,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  strings.splashPreparing,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: .55),
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 40),
                                Text(
                                  strings.splashTagline,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size});

  final double size;

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
