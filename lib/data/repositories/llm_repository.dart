abstract class LlmRepository {
  Future<List<String>> getAvailableModels();
  // Tambahan kantong khusus karakter (systemPrompt)
  Stream<String> streamChat(
    String prompt,
    String model, {
    String? systemPrompt,
  });
  void cancelGeneration();
}
