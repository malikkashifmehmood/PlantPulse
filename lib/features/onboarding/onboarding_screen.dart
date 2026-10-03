import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../auth/auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  int index = 0;

  final slides = const [
    _Slide(
      eyebrow: 'AI CROP HEALTH',
      title: 'Diagnose crop diseases instantly',
      body: 'Capture a clear leaf and PlantPulse helps you understand what may be affecting it.',
      icon: Icons.document_scanner_rounded,
      accent: Color(0xFFDDF4E4),
    ),
    _Slide(
      eyebrow: 'THREE SIMPLE STEPS',
      title: 'Snap. Analyze. Treat.',
      body: 'A focused workflow turns one leaf photo into a clear care plan.',
      icon: Icons.auto_awesome_rounded,
      accent: Color(0xFFE9F5DF),
    ),
    _Slide(
      eyebrow: 'PRIVACY FIRST',
      title: 'Works offline',
      body: 'Common crop diseases can be detected with an on-device model without requiring constant internet access.',
      icon: Icons.phonelink_lock_rounded,
      accent: Color(0xFFDFF3ED),
    ),
  ];

  void next() {
    if (index == slides.length - 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
      return;
    }
    controller.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final slide = slides[index];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
              child: Row(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.eco_rounded, color: PlantPulseColors.green),
                      SizedBox(width: 7),
                      Text(
                        'PlantPulse',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (index < slides.length - 1)
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const AuthScreen()),
                        );
                      },
                      child: const Text('Skip'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: slides.length,
                onPageChanged: (value) => setState(() => index = value),
                itemBuilder: (_, i) => _SlideView(slide: slides[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      slides.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == index ? 26 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: i == index
                              ? PlantPulseColors.green
                              : PlantPulseColors.line,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: next,
                    child: Text(index == slides.length - 1 ? 'Get Started' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String body;
  final IconData icon;
  final Color accent;

  const _Slide({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(34),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 28,
                  right: 24,
                  child: Icon(
                    Icons.grass_rounded,
                    size: 80,
                    color: PlantPulseColors.green.withValues(alpha: .12),
                  ),
                ),
                Container(
                  width: 145,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .7),
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: [
                      BoxShadow(
                        color: PlantPulseColors.forest.withValues(alpha: .08),
                        blurRadius: 30,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 72,
                    color: PlantPulseColors.green,
                  ),
                ),
                Positioned(
                  left: 26,
                  bottom: 24,
                  child: _TinyLeaf(),
                ),
                Positioned(
                  right: 26,
                  bottom: 28,
                  child: _TinyLeaf(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            eyebrow,
            style: const TextStyle(
              color: PlantPulseColors.green,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 29,
              height: 1.05,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: PlantPulseColors.muted,
              height: 1.55,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  final _Slide slide;

  const _SlideView({required this.slide});

  @override
  Widget build(BuildContext context) => slide;
}

class _TinyLeaf extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.eco_rounded,
      size: 34,
      color: PlantPulseColors.green.withValues(alpha: .32),
    );
  }
}
