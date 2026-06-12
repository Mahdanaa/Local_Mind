import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/errors/exceptions.dart';
import 'llm_repository.dart';

class OllamaRepositoryImpl implements LlmRepository {
  final String baseUrl = 'http://127.0.0.1:11434';
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
  Stream<String> streamChat(
    String prompt,
    String model, {
    String? systemPrompt,
  }) async* {
    final request = http.Request('POST', Uri.parse('$baseUrl/api/generate'));
    request.headers['Content-Type'] = 'application/json';

    // Susun isi tas kurir
    Map<String, dynamic> bodyData = {
      'model': model,
      'prompt': prompt,
      'stream': true,
    };

    // ✅ Kalau ada buku karakter, masukin ke tas!
    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      bodyData['system'] = systemPrompt;
    }

    request.body = jsonEncode(bodyData);

    try {
      final response = await _client.send(request);

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
      throw OllamaOfflineException('Anda memberhentikan jawaban.');
    }
  }

  @override
  void cancelGeneration() {
    _client.close();
    _client = http.Client();
  }
}
