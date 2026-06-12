abstract class SessionEvent {}

// Perintah untuk memuat semua history chat dari SQLite ke Sidebar
class LoadAllSessions extends SessionEvent {}

// Perintah untuk bikin ruang chat / sesi baru
class CreateNewSession extends SessionEvent {
  final String title;
  final String systemPrompt;

  CreateNewSession({required this.title, required this.systemPrompt});
}
