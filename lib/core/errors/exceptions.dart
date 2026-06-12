// Inheritance: Mewarisi class Exception bawaan Dart
class OllamaOfflineException implements Exception {
  final String message;
  OllamaOfflineException([
    this.message =
        'Ollama tidak berjalan. Pastikan Ollama aktif di localhost:11434',
  ]);

  @override
  String toString() => message;
}

class ModelNotFoundException implements Exception {
  final String message;
  ModelNotFoundException([this.message = 'Model LLM tidak ditemukan.']);

  @override
  String toString() => message;
}
