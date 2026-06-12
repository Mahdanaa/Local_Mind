class ChatSession {
  final String id;
  final String title;
  final String systemPrompt;
  final int
  createdAt; // Simpan waktu pakai angka (timestamp) biar gampang dibaca SQLite

  const ChatSession({
    required this.id,
    required this.title,
    required this.systemPrompt,
    required this.createdAt,
  });

  // Mapping untuk menyimpan ke SQLite secara ketat (tanpa dynamic)
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
      // Buka koper dan pastikan isinya sesuai (Casting ketat)
      id: map['id'] as String,
      title: map['title'] as String,
      systemPrompt: map['system_prompt'] as String,
      createdAt: map['created_at'] as int,
    );
  }
}
