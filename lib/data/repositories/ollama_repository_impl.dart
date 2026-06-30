import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/errors/exceptions.dart';
import '../models/chat_message.dart';
import 'llm_repository.dart';

class OllamaRepositoryImpl implements LlmRepository {
  final String baseUrl = 'http://127.0.0.1:11434';
  http.Client _client = http.Client();

  @override
  Future<List<String>> getAvailableModels() async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/api/tags'));
      if (response.statusCode == 200) {
        final Map<String, Object?> data =
            jsonDecode(response.body) as Map<String, Object?>;
        final List<Object?> models = data['models'] as List<Object?>;
        return models
            .map((Object? m) =>
                (m as Map<String, Object?>)['name'] as String)
            .toList();
      }
      throw OllamaOfflineException();
    } catch (e) {
      if (e is OllamaOfflineException) rethrow;
      throw OllamaOfflineException();
    }
  }

  @override
  Stream<String> streamChat(List<ChatMessage> messages, String model) async* {
    final request = http.Request('POST', Uri.parse('$baseUrl/api/chat'));
    request.headers['Content-Type'] = 'application/json';

    final Map<String, Object> bodyData = {
      'model': model,
      'messages': messages.map((ChatMessage msg) => msg.toApiMap()).toList(),
      'stream': true,
    };

    request.body = jsonEncode(bodyData);

    try {
      final response = await _client.send(request);

      await for (final String chunk in response.stream.transform(utf8.decoder)) {
        final Iterable<String> lines =
            chunk.split('\n').where((String line) => line.isNotEmpty);
        for (final String line in lines) {
          final Map<String, Object?> data =
              jsonDecode(line) as Map<String, Object?>;
          if (data.containsKey('message')) {
            final Map<String, Object?> message =
                data['message'] as Map<String, Object?>;
            final String token = message['content'] as String? ?? '';
            if (token.isNotEmpty) {
              yield token;
            }
          }
        }
      }
    } catch (e) {
      if (e is OllamaOfflineException) rethrow;
      throw OllamaOfflineException('Anda memberhentikan jawaban.');
    }
  }

  @override
  void cancelGeneration() {
    _client.close();
    _client = http.Client();
  }
}
