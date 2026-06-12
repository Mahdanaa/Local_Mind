abstract class ChatEvent {}

// Saat user menekan tombol "Kirim"
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

// Saat user menekan tombol "Stop"
class StopGenerationEvent extends ChatEvent {}
