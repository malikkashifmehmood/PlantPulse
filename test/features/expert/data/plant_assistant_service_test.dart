import 'package:flutter_test/flutter_test.dart';
import 'package:plantpulse/features/expert/data/plant_assistant_service.dart';
import 'package:plantpulse/features/expert/models/plant_assistant_message.dart';

void main() {
  late PlantAssistantService service;

  setUp(() {
    service = PlantAssistantService();
  });

  test('responds to greetings', () {
    expect(service.getReply('Hello'), contains('PlantPulse Plant Assistant'));
    expect(service.getReply('Salam'), contains('PlantPulse Plant Assistant'));
  });

  test('does not mistake ordinary text for a greeting', () {
    final reply = service.getReply('Is this early blight?');

    expect(reply, contains('Early blight'));
    expect(reply, isNot(contains('Hello!')));
  });

  test('provides guidance for all ten model classes', () {
    final questions = [
      'Tell me about bacterial spot',
      'Tell me about early blight',
      'Tell me about late blight',
      'Tell me about leaf mold',
      'Tell me about Septoria',
      'Tell me about spider mites',
      'Tell me about target spot',
      'Tell me about yellow leaf curl',
      'Tell me about tomato mosaic',
      'Tell me about healthy plants',
    ];

    for (final question in questions) {
      final reply = service.getReply(question);

      expect(reply, isNotEmpty, reason: question);
      expect(reply, isNot(contains('not confident enough')), reason: question);
    }
  });

  test('provides general watering guidance', () {
    expect(service.getReply('How should I water tomatoes?'), contains('soil'));
  });

  test('asks for more details about unclear symptoms', () {
    expect(
      service.getReply('My plant has brown spots'),
      contains('Leaf spots'),
    );
  });

  test('uses detailed symptoms in a direct question', () {
    final reply = service.getReply(
      'The spots are small, dark brown, and have concentric rings. '
      'They mostly appear on older leaves.',
    );

    expect(reply, contains('early blight'));
    expect(reply, contains('Target spot'));
    expect(reply, contains('cannot confirm'));
    expect(reply, isNot(contains('Please describe the spots')));
  });

  test('uses previous messages to understand a symptom follow-up', () {
    final conversation = [
      PlantAssistantMessage(
        id: '1',
        text: 'My tomato plant has brown spots.',
        isUser: true,
        createdAt: DateTime(2026, 11, 14, 10),
      ),
      PlantAssistantMessage(
        id: '2',
        text:
            'Leaf spots can have several causes. Please describe the spots: '
            'are they small or large, do they have rings, and are they '
            'mainly on older or newer leaves?',
        isUser: false,
        createdAt: DateTime(2026, 11, 14, 10, 1),
      ),
    ];

    final reply = service.getReply(
      'They are small, dark brown, and have concentric rings. '
      'They mostly appear on older leaves.',
      conversation: conversation,
    );

    expect(reply, contains('early blight'));
    expect(reply, contains('Target spot'));
    expect(reply, contains('cannot confirm'));
  });

  test('does not reuse old context when no clarification was requested', () {
    final conversation = [
      PlantAssistantMessage(
        id: '1',
        text: 'Tell me about early blight.',
        isUser: true,
        createdAt: DateTime(2026, 11, 14, 10),
      ),
      PlantAssistantMessage(
        id: '2',
        text: 'Early blight commonly causes brown spots with concentric rings.',
        isUser: false,
        createdAt: DateTime(2026, 11, 14, 10, 1),
      ),
    ];

    final reply = service.getReply(
      'What is the weather on Mars?',
      conversation: conversation,
    );

    expect(reply, contains('not confident enough'));
  });

  test('handles an unknown question cautiously', () {
    expect(
      service.getReply('What is the weather on Mars?'),
      contains('not confident enough'),
    );
  });

  test('handles empty input', () {
    expect(service.getReply(''), contains('Please describe'));
  });
}
