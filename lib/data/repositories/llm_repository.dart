import '../models/chat_message.dart';

abstract class LlmRepository {
  Future<List<String>> getAvailableModels();
  Stream<String> streamChat(List<ChatMessage> messages, String model);

  void cancelGeneration();
}
