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
      // 1. Ambil riwayat chat lama dari Brankas
      final existingMessages = await _dbHelper.getMessagesBySession(
        event.sessionId,
      );

      // 2. Bikin pesan user & simpan
      final userMsg = ChatMessage(
        id: _uuid.v4(),
        sessionId: event.sessionId,
        role: 'user',
        content: event.text,
      );
      await _dbHelper.insertMessage(userMsg);
      existingMessages.add(userMsg); // Tambahkan ke daftar tampilan

      emit(ChatLoading(existingMessages)); // Tampilkan UI loading

      try {
        final stream = _repository.streamChat(event.text, event.modelName);
        String fullAiResponse = "";

        // 3. Streaming kata per kata
        await emit.forEach(
          stream,
          onData: (String chunk) {
            fullAiResponse += chunk;
            // Kirim riwayat lama + teks yang lagi diketik AI
            return ChatStreaming(existingMessages, fullAiResponse);
          },
        );

        // 4. Selesai ngetik, simpan pesan AI
        final aiMsg = ChatMessage(
          id: _uuid.v4(),
          sessionId: event.sessionId,
          role: 'assistant',
          content: fullAiResponse,
        );
        await _dbHelper.insertMessage(aiMsg);
        existingMessages.add(aiMsg);

        // 5. Berhasil! Tampilkan semua riwayat
        emit(ChatSuccess(existingMessages));
      } catch (e) {
        emit(ChatError(existingMessages, e.toString()));
      }
    });

    on<StopGenerationEvent>((event, emit) {
      _repository.cancelGeneration();
      emit(ChatSuccess(state.messages)); // Tetap pertahankan chat yang ada
    });
  }
}
