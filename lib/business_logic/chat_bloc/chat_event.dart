import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class SendMessageEvent extends ChatEvent {
  final String text;
  final String modelName;
  final String sessionId;

  const SendMessageEvent({
    required this.text,
    required this.modelName,
    required this.sessionId,
  });

  @override
  List<Object?> get props => [text, modelName, sessionId];
}

class StopGenerationEvent extends ChatEvent {
  const StopGenerationEvent();
}

class LoadChatHistory extends ChatEvent {
  final String sessionId;
  const LoadChatHistory(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class FetchModelsEvent extends ChatEvent {
  const FetchModelsEvent();
}
