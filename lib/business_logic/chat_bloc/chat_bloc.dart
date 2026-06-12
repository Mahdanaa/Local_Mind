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
  final _uuid = const Uuid(); // Buat bikin ID unik acak

  ChatBloc(this._repository, this._dbHelper) : super(ChatInitial()) {
    // ATURAN 1: Kalau ada yang ngirim pesan (SendMessageEvent)
    on<SendMessageEvent>((event, emit) async {
      emit(ChatLoading()); // Kasih tau UI buat tampilin loading

      // 1. Simpan pesan User ke Database
      final userMsg = ChatMessage(
        id: _uuid.v4(),
        sessionId: event.sessionId,
        role: 'user',
        content: event.text,
      );
      await _dbHelper.insertMessage(userMsg);

      try {
        // 2. Minta AI mikir (Streaming)
        final stream = _repository.streamChat(event.text, event.modelName);
        String fullAiResponse = "";

        // 3. Tangkap kata per kata dan laporkan ke UI (ChatStreaming)
        await emit.forEach(
          stream,
          onData: (String chunk) {
            fullAiResponse += chunk;
            return ChatStreaming(
              fullAiResponse,
            ); // UI akan otomatis update tiap ada kata baru!
          },
        );

        // 4. Kalau udah selesai ngetik, simpan balasan AI ke Database
        final aiMsg = ChatMessage(
          id: _uuid.v4(),
          sessionId: event.sessionId,
          role: 'assistant',
          content: fullAiResponse,
        );
        await _dbHelper.insertMessage(aiMsg);

        emit(ChatSuccess()); // Kasih tau UI kalau tugas selesai
      } catch (e) {
        emit(ChatError(e.toString()));
      }
    });

    // ATURAN 2: Kalau user klik Stop (StopGenerationEvent)
    on<StopGenerationEvent>((event, emit) {
      _repository.cancelGeneration();
      emit(ChatSuccess()); // Anggap aja selesai secara paksa
    });
  }
}
