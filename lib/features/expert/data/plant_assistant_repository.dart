import 'dart:convert';

import '../../../core/storage/local_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../models/plant_assistant_message.dart';

class PlantAssistantRepository {
  PlantAssistantRepository(this._storage);

  final LocalStorageService _storage;

  static const int maxMessages = 100;

  String _keyForScope(String scope) {
    final normalizedScope = scope.trim();

    if (normalizedScope.isEmpty) {
      throw ArgumentError.value(scope, 'scope', 'Must not be empty.');
    }

    return '${StorageKeys.cachedExpertMessages}_'
        '${Uri.encodeComponent(normalizedScope)}';
  }

  List<PlantAssistantMessage> loadMessages(String scope) {
    final json = _storage.readString(_keyForScope(scope));

    if (json == null || json.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(json);

      if (decoded is! List) {
        throw const FormatException('Stored messages must be a list.');
      }

      final messages =
          decoded.map<PlantAssistantMessage>((item) {
            if (item is! Map) {
              throw const FormatException('Invalid message record.');
            }

            return PlantAssistantMessage.fromJson(
              Map<String, dynamic>.from(item),
            );
          }).toList();

      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return messages;
    } catch (_) {
      throw const FormatException(
        'Saved chat history is invalid or cannot be decoded.',
      );
    }
  }

  Future<void> saveMessages(
    String scope,
    List<PlantAssistantMessage> messages,
  ) async {
    final key = _keyForScope(scope);
    final limitedMessages =
        messages.length > maxMessages
            ? messages.sublist(messages.length - maxMessages)
            : messages;

    final encoded = jsonEncode(
      limitedMessages.map((message) => message.toJson()).toList(),
    );

    await _storage.saveString(key, encoded);
  }

  Future<void> appendMessage(
    String scope,
    PlantAssistantMessage message,
  ) async {
    final messages = loadMessages(scope);
    final existingIndex = messages.indexWhere((item) => item.id == message.id);

    if (existingIndex == -1) {
      messages.add(message);
    } else {
      messages[existingIndex] = message;
    }

    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    await saveMessages(scope, messages);
  }

  Future<void> clearMessages(String scope) {
    return _storage.remove(_keyForScope(scope));
  }
}
