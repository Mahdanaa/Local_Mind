import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../data/repositories/llm_repository.dart';
import '../../data/local_db/sqlite_helper.dart';
import '../../data/models/chat_message.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final LlmRepository _repository;
  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();

  ChatBloc(this._repository, this._dbHelper) : super(ChatInitial()) {
    // ATURAN 1: Kalau ada pesan masuk (Termasuk Auto-Title)
    on<SendMessageEvent>((event, emit) async {
      final existingMessages = await _dbHelper.getMessagesBySession(
        event.sessionId,
      );

      // LOGIKA AUTO-TITLE
      if (existingMessages.isEmpty) {
        String generatedTitle = event.text.length > 30
            ? '${event.text.substring(0, 30)}...'
            : event.text;

        await _dbHelper.updateSessionTitle(event.sessionId, generatedTitle);
      }

      final userMsg = ChatMessage(
        id: _uuid.v4(),
        sessionId: event.sessionId,
        role: 'user',
        content: event.text,
      );
      await _dbHelper.insertMessage(userMsg);
      existingMessages.add(userMsg);

      emit(ChatLoading(existingMessages));

      try {
        final stream = _repository.streamChat(event.text, event.modelName);
        String fullAiResponse = "";

        await emit.forEach(
          stream,
          onData: (String chunk) {
            fullAiResponse += chunk;
            return ChatStreaming(existingMessages, fullAiResponse);
          },
        );

        final aiMsg = ChatMessage(
          id: _uuid.v4(),
          sessionId: event.sessionId,
          role: 'assistant',
          content: fullAiResponse,
        );
        await _dbHelper.insertMessage(aiMsg);
        existingMessages.add(aiMsg);

        emit(ChatSuccess(existingMessages));
      } catch (e) {
        emit(ChatError(existingMessages, e.toString()));
      }
    });

    // ATURAN 2: Kalau user klik Stop
    on<StopGenerationEvent>((event, emit) {
      _repository.cancelGeneration();
      emit(ChatSuccess(state.messages));
    });

    // ATURAN 3: Kalau user pindah meja (Load History)
    on<LoadChatHistory>((event, emit) async {
      emit(ChatLoading([]));
      try {
        final messages = await _dbHelper.getMessagesBySession(event.sessionId);
        emit(ChatSuccess(messages));
      } catch (e) {
        emit(ChatError(state.messages, e.toString()));
      }
    });
  }
}
