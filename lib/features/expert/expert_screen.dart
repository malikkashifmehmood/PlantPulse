import 'package:flutter/material.dart';
import '../../app/app_theme.dart';
import '../../shared/widgets/plantpulse_scaffold.dart';

class ExpertScreen extends StatefulWidget {
  const ExpertScreen({super.key});

  @override
  State<ExpertScreen> createState() => _ExpertScreenState();
}

class _ExpertScreenState extends State<ExpertScreen> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlantPulseScaffold(
      currentIndex: 3,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: PageHeader(
              title: 'Ask an Expert',
              subtitle: 'Discuss a plant issue with support',
              trailing: Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: PlantPulseColors.mint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.support_agent_rounded, color: PlantPulseColors.green),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              children: const [
                _Message(
                  text: 'Hi! I noticed brown spots appearing on my tomato leaves.',
                  mine: true,
                  time: '10:42 AM',
                ),
                SizedBox(height: 12),
                _Message(
                  text: 'Thanks. Please upload a clear photo of the affected leaf and tell me when you first noticed the change.',
                  mine: false,
                  time: '10:43 AM',
                ),
                SizedBox(height: 12),
                _Message(
                  text: 'I first noticed it two days ago. The spots seem to be spreading.',
                  mine: true,
                  time: '10:44 AM',
                ),
                SizedBox(height: 12),
                _Message(
                  text: 'That context is helpful. A fresh scan can also be attached to this conversation.',
                  mine: false,
                  time: '10:44 AM',
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
              child: Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: () {},
                    icon: const Icon(Icons.add_rounded),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Describe your issue...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () {
                      controller.clear();
                    },
                    icon: const Icon(Icons.arrow_upward_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final String text;
  final bool mine;
  final String time;

  const _Message({
    required this.text,
    required this.mine,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                color: mine ? PlantPulseColors.green : Colors.white,
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomRight: Radius.circular(mine ? 5 : 18),
                  bottomLeft: Radius.circular(mine ? 18 : 5),
                ),
                border: mine ? null : Border.all(color: PlantPulseColors.line),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: mine ? Colors.white : PlantPulseColors.ink,
                  height: 1.4,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(color: PlantPulseColors.muted, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}
