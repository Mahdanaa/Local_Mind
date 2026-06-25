abstract class ChatEvent {}

class SendMessageEvent extends ChatEvent {
  final String text;
  final String modelName;
  final String sessionId;

  SendMessageEvent({
    required this.text,
    required this.modelName,
    required this.sessionId,
  });
}

class StopGenerationEvent extends ChatEvent {}

class LoadChatHistory extends ChatEvent {
  final String sessionId;
  LoadChatHistory(this.sessionId);
}
