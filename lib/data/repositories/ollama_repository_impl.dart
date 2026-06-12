import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/errors/exceptions.dart';
import 'llm_repository.dart';

class OllamaRepositoryImpl implements LlmRepository {
  // Ini alamat mesin pembuat kopi (Ollama) di laptopmu
  final String baseUrl = 'http://127.0.0.1:11434';

  // Tukang kurirnya
  http.Client _client = http.Client();

  @override
  Future<List<String>> getAvailableModels() async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/api/tags'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List models = data['models'];
        return models.map((m) => m['name'] as String).toList();
      }
      throw OllamaOfflineException();
    } catch (e) {
      throw OllamaOfflineException();
    }
  }

  @override
  Stream<String> streamChat(String prompt, String model) async* {
    final request = http.Request('POST', Uri.parse('$baseUrl/api/generate'));
    request.headers['Content-Type'] = 'application/json';

    // Pesanan yang mau dikirim ke dapur
    // Pesanan yang mau dikirim ke dapur
    request.body = jsonEncode({
      'model': model,
      'prompt': prompt,
      'stream': true,
      // TAMBAHAN: Kita bisa nyelipin prompt sistem di sini
      // Sayangnya untuk endpoint /api/generate sederhana di Ollama,
      // system prompt efektifnya digabung di pesan atau pakai /api/chat.
      // Untuk MVP ini, Ollama otomatis mengenali parameter 'system' di endpoint generate!
      'system':
          'Kamu adalah asisten AI yang membantu. (Nanti nilainya diambil dari database)',
    });

    try {
      final response = await _client.send(request);

      // Menangkap kata demi kata yang mengalir dari dapur
      await for (var chunk in response.stream.transform(utf8.decoder)) {
        final lines = chunk.split('\n').where((line) => line.isNotEmpty);
        for (var line in lines) {
          final data = jsonDecode(line);
          if (data.containsKey('response')) {
            yield data['response'] as String;
          }
        }
      }
    } catch (e) {
      // ✅ PESANNYA KITA UBAH DI SINI SOB!
      throw OllamaOfflineException('Anda memberhentikan jawaban.');
    }
  }

  @override
  void cancelGeneration() {
    // Memotong kabel paksa kalau user klik tombol "Stop"
    _client.close();
    // Bikin kurir baru biar siap antar pesanan berikutnya
    _client = http.Client();
  }
}
