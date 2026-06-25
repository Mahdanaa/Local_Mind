class ChatSession {
  final String id;
  final String title;
  final String systemPrompt;
  final int createdAt;

  const ChatSession({
    required this.id,
    required this.title,
    required this.systemPrompt,
    required this.createdAt,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'system_prompt': systemPrompt,
      'created_at': createdAt,
    };
  }

  factory ChatSession.fromMap(Map<String, Object?> map) {
    return ChatSession(
      id: map['id'] as String,
      title: map['title'] as String,
      systemPrompt: map['system_prompt'] as String,
      createdAt: map['created_at'] as int,
    );
  }
}
