import 'package:equatable/equatable.dart';

abstract class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllSessions extends SessionEvent {
  const LoadAllSessions();
}

class CreateNewSession extends SessionEvent {
  final String title;
  final String systemPrompt;

  const CreateNewSession({required this.title, required this.systemPrompt});

  @override
  List<Object?> get props => [title, systemPrompt];
}

class RenameSession extends SessionEvent {
  final String sessionId;
  final String newTitle;

  const RenameSession({required this.sessionId, required this.newTitle});

  @override
  List<Object?> get props => [sessionId, newTitle];
}

class DeleteSession extends SessionEvent {
  final String sessionId;

  const DeleteSession(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}
