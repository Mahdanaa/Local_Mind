import '../../data/models/chat_session.dart';

abstract class SessionState {}

class SessionInitial extends SessionState {}

class SessionLoading extends SessionState {}

// Saat resepsionis berhasil ngambil buku tamu dari SQLite
class SessionLoaded extends SessionState {
  final List<ChatSession> sessions;
  SessionLoaded(this.sessions);
}

class SessionError extends SessionState {
  final String message;
  SessionError(this.message);
}
