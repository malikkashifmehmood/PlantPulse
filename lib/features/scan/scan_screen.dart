import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../shared/widgets/plantpulse_scaffold.dart';
import '../analysis/analysis_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool flash = false;

  void capture() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AnalysisScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlantPulseScaffold(
      currentIndex: 2,
      child: Container(
        color: const Color(0xFF152019),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _CameraTexturePainter(),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        _CircleButton(
                          icon: Icons.close_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Scan Leaf',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        _CircleButton(
                          icon: flash ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                          onTap: () => setState(() => flash = !flash),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 280,
                    height: 360,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(34),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .88),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(painter: _LeafPainter()),
                        ),
                        const Positioned(
                          top: 18,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Text(
                              'PLACE ONE LEAF INSIDE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                    child: Column(
                      children: [
                        const Text(
                          'Good lighting • Keep leaf steady • Avoid glare',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                        const SizedBox(height: 18),
                        GestureDetector(
                          onTap: capture,
                          child: Container(
                            width: 76,
                            height: 76,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: .35),
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
    final p = Paint()..shader = const LinearGradient(
      colors: [Color(0xFF223F2C), Color(0xFF516D45), Color(0xFF1E3024)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF72B96B).withValues(alpha: .72)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width * .50, size.height * .83)
      ..cubicTo(
        size.width * .14, size.height * .62,
        size.width * .18, size.height * .19,
        size.width * .56, size.height * .10,
      )
      ..cubicTo(
        size.width * .87, size.height * .18,
        size.width * .88, size.height * .62,
        size.width * .50, size.height * .83,
      )
      ..close();
    canvas.drawPath(path, p);
    final vein = Paint()
      ..color = Colors.white.withValues(alpha: .65)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * .50, size.height * .82),
      Offset(size.width * .56, size.height * .13),
      vein,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
