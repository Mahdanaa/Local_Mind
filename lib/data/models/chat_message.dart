class ChatMessage {
  final String id;
  final String sessionId;
  final String role;
  final String content;

  const ChatMessage({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
  });

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'role': role,
      'content': content,
    };
  }

  Map<String, String> toApiMap() {
    return {'role': role, 'content': content};
  }

  factory ChatMessage.fromMap(Map<String, Object?> map) {
    return ChatMessage(
      id: map['id'] as String,
      sessionId: map['session_id'] as String,
      role: map['role'] as String,
      content: map['content'] as String,
    );
  }
}
