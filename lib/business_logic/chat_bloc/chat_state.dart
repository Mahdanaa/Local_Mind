import '../../data/models/chat_message.dart';

abstract class ChatState {
  final List<ChatMessage> messages;
  ChatState(this.messages);
}

class ChatInitial extends ChatState {
  ChatInitial() : super([]);
}

class ChatLoading extends ChatState {
  ChatLoading(super.messages);
}

class ChatStreaming extends ChatState {
  final String textSoFar;
  ChatStreaming(super.messages, this.textSoFar);
}

class ChatSuccess extends ChatState {
  ChatSuccess(super.messages);
}

class ChatError extends ChatState {
  final String errorMessage;
  ChatError(super.messages, this.errorMessage);
}
