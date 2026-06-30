import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../data/repositories/llm_repository.dart';
import '../../data/local_db/sqlite_helper.dart';
import '../../data/models/chat_message.dart';
import '../../core/errors/exceptions.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final LlmRepository _repository;
  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();

  ChatBloc(this._repository, this._dbHelper) : super(const ChatInitial()) {
    on<FetchModelsEvent>(_onFetchModels);
    on<SendMessageEvent>(_onSendMessage);
    on<StopGenerationEvent>(_onStopGeneration);
    on<LoadChatHistory>(_onLoadChatHistory);
  }

  Future<void> _onFetchModels(
    FetchModelsEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final List<String> models = await _repository.getAvailableModels();
      final String selected = models.isNotEmpty ? models.first : '';
      emit(ModelsLoaded(availableModels: models, selectedModel: selected));
    } on OllamaOfflineException catch (e) {
      emit(ModelsError(errorMessage: e.toString()));
    }
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final List<ChatMessage> existingMessages = await _dbHelper
        .getMessagesBySession(event.sessionId);

    if (existingMessages.isEmpty) {
      final String generatedTitle = event.text.length > 30
          ? '${event.text.substring(0, 30)}...'
          : event.text;
      await _dbHelper.updateSessionTitle(event.sessionId, generatedTitle);
    }

    final ChatMessage userMsg = ChatMessage(
      id: _uuid.v4(),
      sessionId: event.sessionId,
      role: 'user',
      content: event.text,
    );
    await _dbHelper.insertMessage(userMsg);
    existingMessages.add(userMsg);

    emit(
      ChatLoading(
        messages: existingMessages,
        availableModels: state.availableModels,
        selectedModel: state.selectedModel,
      ),
    );

    try {
      final sessionInfo = await _dbHelper.getSessionById(event.sessionId);
      final String? systemPrompt = sessionInfo?.systemPrompt;
      final List<ChatMessage> apiMessages = [];
      if (systemPrompt != null && systemPrompt.isNotEmpty) {
        apiMessages.add(
          ChatMessage(
            id: 'system',
            sessionId: event.sessionId,
            role: 'system',
            content: systemPrompt,
          ),
        );
      }
      apiMessages.addAll(existingMessages);
      final Stream<String> stream = _repository.streamChat(
        apiMessages,
        event.modelName,
      );
      String fullAiResponse = '';
      await emit.forEach(
        stream,
        onData: (String chunk) {
          fullAiResponse += chunk;
          return ChatStreaming(
            messages: existingMessages,
            availableModels: state.availableModels,
            selectedModel: state.selectedModel,
            textSoFar: fullAiResponse,
          );
        },
      );
      final ChatMessage aiMsg = ChatMessage(
        id: _uuid.v4(),
        sessionId: event.sessionId,
        role: 'assistant',
        content: fullAiResponse,
      );
      await _dbHelper.insertMessage(aiMsg);
      existingMessages.add(aiMsg);

      emit(
        ChatSuccess(
          messages: existingMessages,
          availableModels: state.availableModels,
          selectedModel: state.selectedModel,
        ),
      );
    } catch (e) {
      emit(
        ChatError(
          messages: existingMessages,
          availableModels: state.availableModels,
          selectedModel: state.selectedModel,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onStopGeneration(StopGenerationEvent event, Emitter<ChatState> emit) {
    _repository.cancelGeneration();
    emit(
      ChatSuccess(
        messages: state.messages,
        availableModels: state.availableModels,
        selectedModel: state.selectedModel,
      ),
    );
  }

  Future<void> _onLoadChatHistory(
    LoadChatHistory event,
    Emitter<ChatState> emit,
  ) async {
    emit(
      ChatLoading(
        messages: const [],
        availableModels: state.availableModels,
        selectedModel: state.selectedModel,
      ),
    );
    try {
      final List<ChatMessage> messages = await _dbHelper.getMessagesBySession(
        event.sessionId,
      );
      emit(
        ChatSuccess(
          messages: messages,
          availableModels: state.availableModels,
          selectedModel: state.selectedModel,
        ),
      );
    } catch (e) {
      emit(
        ChatError(
          messages: state.messages,
          availableModels: state.availableModels,
          selectedModel: state.selectedModel,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
