class PlantAssistantMessage {
  const PlantAssistantMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.createdAt,
  });

  final String id;
  final String text;
  final bool isUser;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PlantAssistantMessage.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final text = json['text'];
    final isUser = json['isUser'];
    final createdAt = json['createdAt'];

    if (id is! String || id.trim().isEmpty) {
      throw const FormatException('Invalid message ID.');
    }

    if (text is! String || text.trim().isEmpty || text.length > 2000) {
      throw const FormatException('Invalid message text.');
    }

    if (isUser is! bool) {
      throw const FormatException('Invalid message sender.');
    }

    if (createdAt is! String) {
      throw const FormatException('Invalid message timestamp.');
    }

    return PlantAssistantMessage(
      id: id,
      text: text,
      isUser: isUser,
      createdAt: DateTime.parse(createdAt),
    );
  }
}
