abstract class SessionEvent {}

class LoadAllSessions extends SessionEvent {}

class CreateNewSession extends SessionEvent {
  final String title;
  final String systemPrompt;

  CreateNewSession({required this.title, required this.systemPrompt});
}

class RenameSession extends SessionEvent {
  final String sessionId;
  final String newTitle;
  RenameSession({required this.sessionId, required this.newTitle});
}
