class ChatMessage {
  final String id;
  final String sessionId;
  final String role; // Isinya cuma 'user' atau 'assistant'
  final String content;

  const ChatMessage({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
  });

  // Encapsulation: Membungkus logika pengecekan di dalam class
  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  // Mapping untuk masuk/keluar dari SQLite menggunakan Object? yang sangat ketat
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'role': role,
      'content': content,
    };
  }

  factory ChatMessage.fromMap(Map<String, Object?> map) {
    return ChatMessage(
      // Kita "buka koper" dan pastikan isinya String (Casting)
      id: map['id'] as String,
      sessionId: map['session_id'] as String,
      role: map['role'] as String,
      content: map['content'] as String,
    );
  }
}
