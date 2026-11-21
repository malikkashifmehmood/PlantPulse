import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../auth/auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController controller = PageController();
  int index = 0;

  List<_Slide> _slides(AppLocalizations l10n) => [
    _Slide(
      eyebrow: l10n.onboardingEyebrowOne,
      title: l10n.onboardingTitleOne,
      body: l10n.onboardingBodyOne,
      icon: Icons.document_scanner_rounded,
      accent: const Color(0xFFDDF4E4),
    ),
    _Slide(
      eyebrow: l10n.onboardingEyebrowTwo,
      title: l10n.onboardingTitleTwo,
      body: l10n.onboardingBodyTwo,
      icon: Icons.auto_awesome_rounded,
      accent: const Color(0xFFE9F5DF),
    ),
    _Slide(
      eyebrow: l10n.onboardingEyebrowThree,
      title: l10n.onboardingTitleThree,
      body: l10n.onboardingBodyThree,
      icon: Icons.cloud_sync_rounded,
      accent: const Color(0xFFDFF3ED),
    ),
  ];

  void next(int slideCount) {
    if (index == slideCount - 1) {
      openAuth();
      return;
    }

    controller.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void openAuth() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const AuthScreen()),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final slides = _slides(l10n);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 650;

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          22,
                          12,
                          22,
                          4,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  '🌿 PlantPulse',
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              if (index < slides.length - 1)
                                Align(
                                  alignment: AlignmentDirectional.centerEnd,
                                  child: TextButton(
                                    onPressed: openAuth,
                                    child: Text(l10n.skip),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: compact ? 560 : 620,
                        child: PageView.builder(
                          controller: controller,
                          itemCount: slides.length,
                          onPageChanged: (value) {
                            setState(() => index = value);
                          },
                          itemBuilder:
                              (_, i) => _SlideView(
                                slide: slides[i],
                                compact: compact,
                              ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          22,
                          8,
                          22,
                          20,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                slides.length,
                                (i) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  width: i == index ? 26 : 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color:
                                        i == index
                                            ? PlantPulseColors.green
                                            : PlantPulseColors.line,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () => next(slides.length),
                                child: Text(
                                  index == slides.length - 1
                                      ? l10n.getStarted
                                      : l10n.next,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Slide {
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
}

class _SlideView extends StatelessWidget {
  final _Slide slide;
  final bool compact;

  const _SlideView({required this.slide, required this.compact});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageHeight =
            (constraints.maxHeight * 0.30)
                .clamp(110.0, compact ? 170.0 : 230.0)
                .toDouble();

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(22, 8, 22, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: imageHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: slide.accent,
                    borderRadius: BorderRadius.circular(34),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PositionedDirectional(
                        top: 20,
                        end: 24,
                        child: Icon(
                          Icons.grass_rounded,
                          size: 65,
                          color: PlantPulseColors.green.withValues(alpha: .12),
                        ),
                      ),
                      Container(
                        width: 125,
                        height: imageHeight * 0.60,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .7),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: PlantPulseColors.forest.withValues(
                                alpha: .08,
                              ),
                              blurRadius: 30,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Icon(
                          slide.icon,
                          size: 65,
                          color: PlantPulseColors.green,
                        ),
                      ),
                      const PositionedDirectional(
                        start: 26,
                        bottom: 18,
                        child: _TinyLeaf(),
                      ),
                      const PositionedDirectional(
                        end: 26,
                        bottom: 22,
                        child: _TinyLeaf(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: compact ? 12 : 18),
                Text(
                  slide.eyebrow,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: PlantPulseColors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  slide.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: compact ? 25 : 29,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  slide.body,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: PlantPulseColors.muted,
                    height: 1.55,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TinyLeaf extends StatelessWidget {
  const _TinyLeaf();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.eco_rounded,
      size: 34,
      color: PlantPulseColors.green.withValues(alpha: .32),
    );
  }
}
