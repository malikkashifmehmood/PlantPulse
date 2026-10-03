import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../expert/expert_screen.dart';
import '../scan/scan_screen.dart';

class LowConfidenceScreen extends StatelessWidget {
  const LowConfidenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        ),
        title: const Text('Scan result'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
        child: Column(
          children: [
            Container(
              width: 120,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: PlantPulseColors.line),
              ),
              child: const Icon(
                Icons.image_not_supported_outlined,
                color: PlantPulseColors.muted,
                size: 54,
              ),
            ),
            const SizedBox(height: 22),
            const Icon(
              Icons.warning_amber_rounded,
              color: PlantPulseColors.warning,
              size: 38,
            ),
            const SizedBox(height: 10),
            const Text(
              'We can’t tell from this photo',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            const Text(
              'The image is not clear enough for a reliable diagnosis. A better photo will help reduce uncertainty.',
              textAlign: TextAlign.center,
              style: TextStyle(color: PlantPulseColors.muted, height: 1.5),
            ),
            const SizedBox(height: 22),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _Tip(icon: Icons.wb_sunny_outlined, text: 'Use better lighting'),
                    _Tip(icon: Icons.crop_free_rounded, text: 'Keep the leaf inside the frame'),
                    _Tip(icon: Icons.pan_tool_alt_outlined, text: 'Hold the phone steady'),
                  ],
                ),
              ),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ScanScreen()),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retake photo'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExpertScreen()),
              ),
              icon: const Icon(Icons.support_agent_rounded),
              label: const Text('Ask an expert'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Tip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: PlantPulseColors.green),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
