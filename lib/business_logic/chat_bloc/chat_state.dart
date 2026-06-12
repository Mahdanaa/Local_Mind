abstract class ChatState {}

// Tampilan awal (kosong)
class ChatInitial extends ChatState {}

// Saat nunggu AI mikir (Muncul animasi muter/loading)
class ChatLoading extends ChatState {}

// Saat AI lagi ngetik kata per kata
class ChatStreaming extends ChatState {
  final String textSoFar;
  ChatStreaming(this.textSoFar);
}

// Saat AI udah selesai ngetik
class ChatSuccess extends ChatState {}

// Saat ada masalah (Ollama mati, dll)
class ChatError extends ChatState {
  final String errorMessage;
  ChatError(this.errorMessage);
}
