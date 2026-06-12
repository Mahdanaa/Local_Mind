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
    on<SendMessageEvent>((event, emit) async {
      final existingMessages = await _dbHelper.getMessagesBySession(
        event.sessionId,
      );

      // 1. AUTO-TITLE
      if (existingMessages.isEmpty) {
        String generatedTitle = event.text.length > 30
            ? '${event.text.substring(0, 30)}...'
            : event.text;

        await _dbHelper.updateSessionTitle(event.sessionId, generatedTitle);
      }

      // 2. SIMPAN PESAN USER
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
        // ✅ 3. NGINTIP KARAKTER DARI BRANKAS
        final sessionInfo = await _dbHelper.getSessionById(event.sessionId);
        final karakterAi = sessionInfo?.systemPrompt;

        // ✅ 4. KASIH KARAKTERNYA KE KURIR AI
        final stream = _repository.streamChat(
          event.text,
          event.modelName,
          systemPrompt: karakterAi, // Berikan karakternya ke Ollama!
        );

        String fullAiResponse = "";

        // 5. STREAMING BALASAN AI
        await emit.forEach(
          stream,
          onData: (String chunk) {
            fullAiResponse += chunk;
            return ChatStreaming(existingMessages, fullAiResponse);
          },
        );

        // 6. SIMPAN PESAN AI
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

    on<StopGenerationEvent>((event, emit) {
      _repository.cancelGeneration();
      emit(ChatSuccess(state.messages));
    });

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
