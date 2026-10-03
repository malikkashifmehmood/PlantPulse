import 'dart:async';
import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../diagnosis/diagnosis_screen.dart';
import '../scan/low_confidence_screen.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  double progress = .0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 180), (t) {
      if (!mounted) return;
      setState(() {
        progress = (progress + .035).clamp(0, 1);
      });
      if (progress >= 1) {
        t.cancel();
        Future.delayed(const Duration(milliseconds: 350), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DiagnosisScreen()),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();
    final steps = [
      ('Image quality', progress > .12),
      ('Leaf segmentation', progress > .30),
      ('Pigment analysis', progress > .48),
      ('Vein analysis', progress > .66),
      ('Pathology check', progress > .84),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        ),
        title: const Text('Analysis'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: PlantPulseColors.mint,
                shape: BoxShape.circle,
                border: Border.all(color: PlantPulseColors.line, width: 8),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    color: PlantPulseColors.green,
                    backgroundColor: Colors.white,
                  ),
                  const Icon(
                    Icons.eco_rounded,
                    size: 48,
                    color: PlantPulseColors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Analyzing your leaf',
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Running several image checks before showing a result.',
              textAlign: TextAlign.center,
              style: TextStyle(color: PlantPulseColors.muted, height: 1.45),
            ),
            const SizedBox(height: 22),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(100),
            ),
            const SizedBox(height: 8),
            Text(
              '$percent%',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    for (final step in steps)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Row(
                          children: [
                            Icon(
                              step.$2
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              size: 20,
                              color: step.$2
                                  ? PlantPulseColors.green
                                  : PlantPulseColors.line,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                step.$1,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LowConfidenceScreen()),
                );
              },
              child: const Text('Preview low-confidence state'),
            ),
          ],
        ),
      ),
    );
  }
}
