import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plantpulse/core/storage/local_storage_service.dart';
import 'package:plantpulse/core/storage/storage_keys.dart';
import 'package:plantpulse/features/expert/data/plant_assistant_repository.dart';
import 'package:plantpulse/features/expert/models/plant_assistant_message.dart';

void main() {
  late SharedPreferences preferences;
  late PlantAssistantRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    repository = PlantAssistantRepository(LocalStorageService(preferences));
  });

  PlantAssistantMessage createMessage({
    required String id,
    String? text,
    bool isUser = true,
    DateTime? createdAt,
  }) {
    return PlantAssistantMessage(
      id: id,
      text: text ?? 'Test message $id',
      isUser: isUser,
      createdAt: createdAt ?? DateTime(2026, 11, 17),
    );
  }

  test('returns an empty list when no history exists', () {
    expect(repository.loadMessages('guest'), isEmpty);
  });

  test('saves and loads messages correctly', () async {
    final messages = [
      createMessage(id: '1', text: 'Hello'),
      createMessage(id: '2', text: 'How can I help?', isUser: false),
    ];

    await repository.saveMessages('guest', messages);

    final loaded = repository.loadMessages('guest');

    expect(loaded, hasLength(2));
    expect(loaded[0].id, '1');
    expect(loaded[0].text, 'Hello');
    expect(loaded[0].isUser, isTrue);
    expect(loaded[1].id, '2');
    expect(loaded[1].text, 'How can I help?');
    expect(loaded[1].isUser, isFalse);
  });

  test('keeps guest and authenticated user histories separate', () async {
    await repository.saveMessages('guest', [
      createMessage(id: 'guest-1', text: 'Guest conversation'),
    ]);

    await repository.saveMessages('user-123', [
      createMessage(id: 'user-1', text: 'Private conversation'),
    ]);

    expect(repository.loadMessages('guest').single.text, 'Guest conversation');
    expect(
      repository.loadMessages('user-123').single.text,
      'Private conversation',
    );
  });

  test('supports scopes containing special characters', () async {
    const scope = 'user/example@example.com';

    await repository.saveMessages(scope, [
      createMessage(id: '1', text: 'Scoped conversation'),
    ]);

    expect(repository.loadMessages(scope).single.text, 'Scoped conversation');

    expect(
      preferences.getString(
        '${StorageKeys.cachedExpertMessages}_'
        '${Uri.encodeComponent(scope)}',
      ),
      isNotNull,
    );
  });

  test('rejects an empty or whitespace-only scope', () {
    expect(() => repository.loadMessages(''), throwsArgumentError);

    expect(() => repository.loadMessages('   '), throwsArgumentError);
  });

  test('loads messages in chronological order', () async {
    await repository.saveMessages('guest', [
      createMessage(id: 'later', createdAt: DateTime(2026, 11, 17, 12)),
      createMessage(id: 'earlier', createdAt: DateTime(2026, 11, 17, 10)),
      createMessage(id: 'middle', createdAt: DateTime(2026, 11, 17, 11)),
    ]);

    final loaded = repository.loadMessages('guest');

    expect(loaded.map((message) => message.id).toList(), [
      'earlier',
      'middle',
      'later',
    ]);
  });

  test('appends a new message without losing existing messages', () async {
    await repository.saveMessages('guest', [createMessage(id: '1')]);

    await repository.appendMessage('guest', createMessage(id: '2'));

    final loaded = repository.loadMessages('guest');

    expect(loaded, hasLength(2));
    expect(loaded.map((message) => message.id), ['1', '2']);
  });

  test('replaces an existing message when its ID is duplicated', () async {
    await repository.saveMessages('guest', [
      createMessage(id: '1', text: 'Original message'),
      createMessage(id: '2', text: 'Another message'),
    ]);

    await repository.appendMessage(
      'guest',
      createMessage(
        id: '1',
        text: 'Updated message',
        createdAt: DateTime(2026, 11, 18),
      ),
    );

    final loaded = repository.loadMessages('guest');

    expect(loaded, hasLength(2));
    expect(
      loaded.where((message) => message.id == '1').single.text,
      'Updated message',
    );
  });

  test('limits saved history to the latest 100 messages', () async {
    final messages = List.generate(
      105,
      (index) => createMessage(
        id: 'message-$index',
        createdAt: DateTime(2026, 11, 17).add(Duration(minutes: index)),
      ),
    );

    await repository.saveMessages('guest', messages);

    final loaded = repository.loadMessages('guest');

    expect(loaded, hasLength(100));
    expect(loaded.first.id, 'message-5');
    expect(loaded.last.id, 'message-104');
  });

  test('rejects invalid saved JSON', () async {
    await preferences.setString(
      '${StorageKeys.cachedExpertMessages}_guest',
      '{invalid-json',
    );

    expect(
      () => repository.loadMessages('guest'),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects saved data that is not a list', () async {
    await preferences.setString(
      '${StorageKeys.cachedExpertMessages}_guest',
      '{"message":"not a list"}',
    );

    expect(
      () => repository.loadMessages('guest'),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects malformed message records', () async {
    await preferences.setString(
      '${StorageKeys.cachedExpertMessages}_guest',
      '[{"id":"","text":"Invalid","isUser":true,'
          '"createdAt":"2026-11-17T10:00:00.000"}]',
    );

    expect(
      () => repository.loadMessages('guest'),
      throwsA(isA<FormatException>()),
    );
  });

  test('clears only the selected conversation', () async {
    await repository.saveMessages('guest', [createMessage(id: 'guest-1')]);

    await repository.saveMessages('user-123', [createMessage(id: 'user-1')]);

    await preferences.setString(
      StorageKeys.cachedPlants,
      'unrelated plant data',
    );

    await repository.clearMessages('guest');

    expect(repository.loadMessages('guest'), isEmpty);
    expect(repository.loadMessages('user-123'), hasLength(1));
    expect(
      preferences.getString(StorageKeys.cachedPlants),
      'unrelated plant data',
    );
  });

  test('clearing an already empty conversation is safe', () async {
    await repository.clearMessages('guest');

    expect(repository.loadMessages('guest'), isEmpty);
  });
}
