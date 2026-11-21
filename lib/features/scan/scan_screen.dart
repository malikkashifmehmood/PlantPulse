import 'dart:io';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/app.dart';
import '../../core/models/plant.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/plantpulse_scaffold.dart';
import '../analysis/analysis_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key, this.plant});

  final Plant? plant;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  bool _openingAnalysis = false;
  late final AnimationController _scanController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  )..repeat(reverse: true);
  final ImagePicker _imagePicker = ImagePicker();

  String get _scope {
    if (Firebase.apps.isEmpty) return 'guest';

    try {
      return FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    } catch (_) {
      return 'guest';
    }
  }

  Future<void> capture() async {
    if (_openingAnalysis) return;

    setState(() => _openingAnalysis = true);

    try {
      final l10n = AppLocalizations.of(context);
      Plant? selectedPlant = widget.plant;

      if (selectedPlant == null) {
        final plants = AppServicesScope.of(context).plants.loadPlants(_scope);

        if (plants.isEmpty) {
          if (!mounted) return;

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.addPlantBeforeScan)));
          return;
        }

        selectedPlant = await showDialog<Plant>(
          context: context,
          builder:
              (dialogContext) => AlertDialog(
                title: Text(l10n.choosePlant),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: plants.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final plant = plants[index];

                      return ListTile(
                        leading: const Icon(
                          Icons.eco_rounded,
                          color: Color(0xFF36764A),
                        ),
                        title: Text(plant.name),
                        subtitle: Text(plant.species),
                        onTap: () => Navigator.pop(dialogContext, plant),
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(l10n.cancel),
                  ),
                ],
              ),
        );

        if (selectedPlant == null || !mounted) return;
      }

      final pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 95,
        maxWidth: 2048,
        maxHeight: 2048,
      );

      if (!mounted || pickedImage == null) return;

      final imageFile = File(pickedImage.path);
      final imageSize = await imageFile.length();

      if (imageSize == 0 || imageSize > 8 * 1024 * 1024) {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.invalidScanImage)));
        return;
      }

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder:
              (_) =>
                  AnalysisScreen(plant: selectedPlant!, imageFile: imageFile),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).imageSelectionFailed),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _openingAnalysis = false);
      }
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tips = l10n.scanImageTips;
    // The English tips string is stored with broken characters; fall back to
    // clean chips instead of showing it.
    final tipsBroken = RegExp(r'[\u00C3\u00E2\u00C2]').hasMatch(tips);

    return PlantPulseScaffold(
      currentIndex: 2,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF062416), Color(0xFF0B3D22), Color(0xFF0D4A2A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _CameraTexturePainter()),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final frameWidth = math.min(290.0, constraints.maxWidth - 48);
                  final frameHeight = math.min(380.0, frameWidth * 1.3);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                            child: Row(
                              children: [
                                _CircleButton(
                                  icon: Icons.close_rounded,
                                  onTap: () => Navigator.pop(context),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    widget.plant == null
                                        ? l10n.scanLeaf
                                        : l10n.scanPlant(widget.plant!.name),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'serif',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.photo_library_outlined,
                                  color: Color(0xFFBFE8CB),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          Center(
                            child: Container(
                              width: frameWidth,
                              height: frameHeight,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                color: Colors.white.withValues(alpha: .05),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: .16),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF35B968,
                                    ).withValues(alpha: .18),
                                    blurRadius: 40,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(32),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: _LeafPainter(),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: _ScanLinePainter(
                                          _scanController,
                                        ),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: _CornerBracketsPainter(),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 20,
                                      left: 16,
                                      right: 16,
                                      child: Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 7,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(
                                              alpha: .28,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Text(
                                            l10n.selectLeafImage,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: .6,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 26),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            child: Column(
                              children: [
                                if (tipsBroken)
                                  const Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _TipChip(
                                        icon: Icons.wb_sunny_outlined,
                                        label: 'Good lighting',
                                      ),
                                      _TipChip(
                                        icon: Icons.eco_outlined,
                                        label: 'Keep leaf clear',
                                      ),
                                      _TipChip(
                                        icon: Icons.flare_rounded,
                                        label: 'Avoid glare',
                                      ),
                                    ],
                                  )
                                else
                                  Text(
                                    tips,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFFBFE8CB),
                                      fontSize: 12,
                                      height: 1.5,
                                    ),
                                  ),
                                if (widget.plant != null) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    l10n.plantLabel(widget.plant!.name),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'serif',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 22),
                                Semantics(
                                  button: true,
                                  label: l10n.chooseFromGallery,
                                  child: GestureDetector(
                                    onTap: _openingAnalysis ? null : capture,
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFF7FDB9F),
                                          width: 3,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF35B968,
                                            ).withValues(alpha: .35),
                                            blurRadius: 24,
                                          ),
                                        ],
                                      ),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                        child:
                                            _openingAnalysis
                                                ? const Padding(
                                                  padding: EdgeInsets.all(18),
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 3,
                                                        color: Color(
                                                          0xFF168447,
                                                        ),
                                                      ),
                                                )
                                                : const Icon(
                                                  Icons.photo_library_rounded,
                                                  color: Color(0xFF0D4A2A),
                                                  size: 32,
                                                ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.chooseFromGallery,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

class _TipChip extends StatelessWidget {
  const _TipChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: .14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF7FDB9F)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFDDF3E4),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: .10),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}

class _CameraTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final glow =
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFF35B968).withValues(alpha: .22),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * .5, size.height * .36),
              radius: size.width * .8,
            ),
          );

    canvas.drawRect(Offset.zero & size, glow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path =
        Path()
          ..moveTo(w * .50, h * .80)
          ..cubicTo(w * .12, h * .60, w * .16, h * .20, w * .54, h * .10)
          ..cubicTo(w * .88, h * .18, w * .90, h * .60, w * .50, h * .80)
          ..close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF7FDB9F), Color(0xFF168447)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Offset.zero & size),
    );

    final vein =
        Paint()
          ..color = Colors.white.withValues(alpha: .55)
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(w * .50, h * .79), Offset(w * .54, h * .13), vein);

    vein.strokeWidth = 1.4;
    vein.color = Colors.white.withValues(alpha: .35);
    for (final t in [.28, .42, .56, .68]) {
      final y = h * (.80 - t * .70);
      final x = w * (.50 + (.54 - .50) * t);
      canvas.drawLine(Offset(x, y), Offset(x - w * .20, y - h * .06), vein);
      canvas.drawLine(Offset(x, y), Offset(x + w * .20, y - h * .06), vein);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScanLinePainter extends CustomPainter {
  _ScanLinePainter(this.animation) : super(repaint: animation);

  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * (.08 + .84 * animation.value);

    final band =
        Paint()
          ..shader = LinearGradient(
            colors: [
              Colors.transparent,
              const Color(0xFF7FDB9F).withValues(alpha: .35),
              Colors.transparent,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, y - 28, size.width, 56));

    canvas.drawRect(Rect.fromLTWH(0, y - 28, size.width, 56), band);

    canvas.drawLine(
      Offset(size.width * .06, y),
      Offset(size.width * .94, y),
      Paint()
        ..color = const Color(0xFFB8F5CC)
        ..strokeWidth = 1.6,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanLinePainter oldDelegate) => false;
}

class _CornerBracketsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const inset = 18.0;
    const len = 26.0;
    final p =
        Paint()
          ..color = Colors.white.withValues(alpha: .9)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    canvas.drawPath(
      Path()
        ..moveTo(inset, inset + len)
        ..lineTo(inset, inset)
        ..lineTo(inset + len, inset)
        ..moveTo(w - inset - len, inset)
        ..lineTo(w - inset, inset)
        ..lineTo(w - inset, inset + len)
        ..moveTo(inset, h - inset - len)
        ..lineTo(inset, h - inset)
        ..lineTo(inset + len, h - inset)
        ..moveTo(w - inset - len, h - inset)
        ..lineTo(w - inset, h - inset)
        ..lineTo(w - inset, h - inset - len),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
