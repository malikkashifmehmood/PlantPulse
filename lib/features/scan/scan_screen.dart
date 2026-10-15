import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/app.dart';
import '../../core/models/plant.dart';
import '../../shared/widgets/plantpulse_scaffold.dart';
import '../analysis/analysis_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key, this.plant});

  final Plant? plant;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _openingAnalysis = false;
  final ImagePicker _imagePicker = ImagePicker();

  String get _scope => FirebaseAuth.instance.currentUser?.uid ?? 'guest';

  Future<void> capture() async {
    if (_openingAnalysis) return;

    setState(() => _openingAnalysis = true);

    try {
      Plant? selectedPlant = widget.plant;

      if (selectedPlant == null) {
        final plants = AppServicesScope.of(context).plants.loadPlants(_scope);

        if (plants.isEmpty) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add a plant in My Plants before starting a scan.'),
            ),
          );
          return;
        }

        selectedPlant = await showDialog<Plant>(
          context: context,
          builder:
              (dialogContext) => AlertDialog(
                title: const Text('Choose a plant'),
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
                    child: const Text('Cancel'),
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

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Choose a valid image smaller than 8 MB.'),
          ),
        );
        return;
      }

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder:
              (_) => AnalysisScreen(plant: selectedPlant, imageFile: imageFile),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to select the image. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _openingAnalysis = false);
      }
    }
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
              child: CustomPaint(painter: _CameraTexturePainter()),
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
                        Expanded(
                          child: Text(
                            widget.plant == null
                                ? 'Scan Leaf'
                                : 'Scan ${widget.plant!.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.photo_library_outlined,
                          color: Colors.white,
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
                              'SELECT A LEAF IMAGE',
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
                          'Good lighting • Keep leaf clear • Avoid glare',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                        if (widget.plant != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Plant: ${widget.plant!.name}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        GestureDetector(
                          onTap: _openingAnalysis ? null : capture,
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
                              child:
                                  _openingAnalysis
                                      ? const Padding(
                                        padding: EdgeInsets.all(15),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                        ),
                                      )
                                      : const Icon(
                                        Icons.photo_library_rounded,
                                        color: Color(0xFF36764A),
                                        size: 30,
                                      ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Choose from gallery',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
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
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

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
    final paint =
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF223F2C), Color(0xFF516D45), Color(0xFF1E3024)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF72B96B).withValues(alpha: .72)
          ..style = PaintingStyle.fill;

    final path =
        Path()
          ..moveTo(size.width * .50, size.height * .83)
          ..cubicTo(
            size.width * .14,
            size.height * .62,
            size.width * .18,
            size.height * .19,
            size.width * .56,
            size.height * .10,
          )
          ..cubicTo(
            size.width * .87,
            size.height * .18,
            size.width * .88,
            size.height * .62,
            size.width * .50,
            size.height * .83,
          )
          ..close();

    canvas.drawPath(path, paint);

    final vein =
        Paint()
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
