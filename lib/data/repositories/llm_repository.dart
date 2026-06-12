abstract class LlmRepository {
  /// Mengambil daftar model yang sudah di-download user
  Future<List<String>> getAvailableModels();

  /// Mengirim pesan dan menerima balasan secara streaming (kata per kata)
  Stream<String> streamChat(String prompt, String model);

  /// Membatalkan proses AI yang sedang berjalan
  void cancelGeneration();
}
