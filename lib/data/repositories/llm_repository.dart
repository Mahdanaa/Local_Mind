abstract class LlmRepository {
  Future<List<String>> getAvailableModels();
  Stream<String> streamChat(
    String prompt,
    String model, {
    String? systemPrompt,
  });
  void cancelGeneration();
}
