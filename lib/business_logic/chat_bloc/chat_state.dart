import 'package:equatable/equatable.dart';
import '../../data/models/chat_message.dart';

abstract class ChatState extends Equatable {
  final List<ChatMessage> messages;
  final List<String> availableModels;
  final String selectedModel;

  const ChatState({
    this.messages = const [],
    this.availableModels = const [],
    this.selectedModel = '',
  });

  @override
  List<Object?> get props => [messages, availableModels, selectedModel];
}

class ChatInitial extends ChatState {
  const ChatInitial() : super();
}

class ChatLoading extends ChatState {
  const ChatLoading({
    required super.messages,
    required super.availableModels,
    required super.selectedModel,
  });
}

class ChatStreaming extends ChatState {
  final String textSoFar;

  const ChatStreaming({
    required super.messages,
    required super.availableModels,
    required super.selectedModel,
    required this.textSoFar,
  });

  @override
  List<Object?> get props =>
      [messages, availableModels, selectedModel, textSoFar];
}

class ChatSuccess extends ChatState {
  const ChatSuccess({
    required super.messages,
    required super.availableModels,
    required super.selectedModel,
  });
}

class ChatError extends ChatState {
  final String errorMessage;

  const ChatError({
    required super.messages,
    required super.availableModels,
    required super.selectedModel,
    required this.errorMessage,
  });

  @override
  List<Object?> get props =>
      [messages, availableModels, selectedModel, errorMessage];
}

class ModelsLoaded extends ChatState {
  const ModelsLoaded({
    required super.availableModels,
    required super.selectedModel,
  });
}

class ModelsError extends ChatState {
  final String errorMessage;

  const ModelsError({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
