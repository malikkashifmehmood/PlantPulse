import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../shared/widgets/plantpulse_scaffold.dart';
import '../expert/expert_screen.dart';
import '../treatment/treatment_screen.dart';

class DiagnosisScreen extends StatelessWidget {
  const DiagnosisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Diagnosis'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border_rounded)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 230,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8F4DF), Color(0xFFBCDCA9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(Icons.eco_rounded, size: 100, color: PlantPulseColors.green),
              ),
            ),
            const SizedBox(height: 18),
            const Row(
              children: [
                Expanded(
                  child: Text(
                    'Early Blight',
                    style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900),
                  ),
                ),
                StatusPill(
                  text: '92% confidence',
                  background: PlantPulseColors.successBg,
                  foreground: PlantPulseColors.green,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Tomato Roma • Scan just now',
              style: TextStyle(color: PlantPulseColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 20),
            const _ConfidenceCard(),
            const SizedBox(height: 18),
            const Text(
              'Visible symptoms',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            const _Symptom(text: 'Circular brown lesions'),
            const _Symptom(text: 'Yellowing around affected areas'),
            const _Symptom(text: 'Leaf deterioration'),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TreatmentScreen()),
              ),
              child: const Text('View Treatment Plan'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.bookmark_border_rounded),
                    label: const Text('Save'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ExpertScreen()),
                    ),
                    icon: const Icon(Icons.support_agent_rounded),
                    label: const Text('Expert'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfidenceCard extends StatelessWidget {
  const _ConfidenceCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 62,
              height: 62,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: .92,
                    strokeWidth: 7,
                    color: PlantPulseColors.green,
                    backgroundColor: PlantPulseColors.mint,
                  ),
                  const Text(
                    '92',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI confidence', style: TextStyle(fontWeight: FontWeight.w900)),
                  SizedBox(height: 4),
                  Text(
                    'This result is based on the visible features in the captured image.',
                    style: TextStyle(color: PlantPulseColors.muted, fontSize: 11, height: 1.4),
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

class _Symptom extends StatelessWidget {
  final String text;

  const _Symptom({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: PlantPulseColors.green, size: 19),
          const SizedBox(width: 9),
          Text(text),
        ],
      ),
    );
  }
}
