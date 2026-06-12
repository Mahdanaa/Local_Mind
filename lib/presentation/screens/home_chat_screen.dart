import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../business_logic/chat_bloc/chat_bloc.dart';
import '../../business_logic/chat_bloc/chat_event.dart';
import '../../business_logic/chat_bloc/chat_state.dart';
import '../widgets/chat_bubble.dart';

class HomeChatScreen extends StatefulWidget {
  const HomeChatScreen({super.key});

  @override
  State<HomeChatScreen> createState() => _HomeChatScreenState();
}

class _HomeChatScreenState extends State<HomeChatScreen> {
  final TextEditingController _textController = TextEditingController();
  // Untuk MVP, kita hardcode model dan ID sesi-nya dulu biar gampang tes
  final String _currentModel = 'qwen2.5:0.5b';
  final String _currentSessionId = 'sesi-tes-123';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // KIRI: Sidebar (Sementara masih kosong)
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[100],
              child: const Center(child: Text('Sidebar Riwayat Chat')),
            ),
          ),

          const VerticalDivider(width: 1, thickness: 1),

          // KANAN: Chat Area
          Expanded(
            flex: 5,
            child: Column(
              children: [
                // 1. AREA TAMPILAN BALON CHAT
                Expanded(
                  child: BlocBuilder<ChatBloc, ChatState>(
                    builder: (context, state) {
                      // 1. Susun piring-piring berisi pesan lama dari SQLite
                      List<Widget> chatBubbles = state.messages.map<Widget>((
                        msg,
                      ) {
                        return ChatBubble(
                          text: msg.content,
                          isUser: msg.isUser,
                        );
                      }).toList();
                      // 2. Tambahkan animasi loading, teks yang sedang diketik, atau error
                      if (state is ChatStreaming) {
                        chatBubbles.add(
                          ChatBubble(text: state.textSoFar, isUser: false),
                        );
                      } else if (state is ChatLoading) {
                        chatBubbles.add(
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        );
                      } else if (state is ChatError) {
                        chatBubbles.add(
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Error: ${state.errorMessage}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                        );
                      }

                      // 3. Tampilkan mejanya
                      if (chatBubbles.isEmpty) {
                        return const Center(
                          child: Text('Mulai obrolan baru...'),
                        );
                      }

                      return ListView(
                        padding: const EdgeInsets.all(16),
                        children: chatBubbles,
                      );
                    },
                  ),
                ),

                // 2. AREA INPUT TEKS
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          decoration: const InputDecoration(
                            hintText: 'Tanya sesuatu ke AI lokal...',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (val) =>
                              _sendMessage(), // Kirim pakai Enter
                        ),
                      ),
                      const SizedBox(width: 12),
                      FloatingActionButton(
                        onPressed: _sendMessage,
                        backgroundColor: Colors.teal,
                        child: const Icon(Icons.send, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;

    // Kirim pesanan ke Manajer (ChatBloc)
    context.read<ChatBloc>().add(
      SendMessageEvent(
        text: _textController.text,
        modelName: _currentModel, // Pastikan model ini sudah kamu 'ollama run'
        sessionId: _currentSessionId,
      ),
    );

    _textController.clear();
  }
}
