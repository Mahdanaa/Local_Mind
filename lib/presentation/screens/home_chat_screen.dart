import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_mind/business_logic/session_bloc/session_bloc.dart';
import 'package:local_mind/business_logic/session_bloc/session_event.dart';
import '../../business_logic/chat_bloc/chat_bloc.dart';
import '../../business_logic/chat_bloc/chat_event.dart';
import '../../business_logic/chat_bloc/chat_state.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/sidebar_history.dart';

class HomeChatScreen extends StatefulWidget {
  const HomeChatScreen({super.key});

  @override
  State<HomeChatScreen> createState() => _HomeChatScreenState();
}

class _HomeChatScreenState extends State<HomeChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final String _currentModel = 'qwen2.5:0.5b';

  // Sekarang ID Sesi bisa berubah-ubah, jadi kita pakai null di awal
  String? _currentSessionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ==========================
          // KIRI: Sidebar Resepsionis
          // ==========================
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[100],
              child: SidebarHistory(
                onSessionSelected: (String sessionId) {
                  setState(() {
                    _currentSessionId = sessionId; // Update meja aktif
                  });
                  // Suruh manajer ambil riwayat chat di meja ini
                  context.read<ChatBloc>().add(LoadChatHistory(sessionId));
                },
              ),
            ),
          ),

          const VerticalDivider(width: 1, thickness: 1),

          // ==========================
          // KANAN: Chat Area
          // ==========================
          Expanded(
            flex: 5,
            // Kalau belum milih room chat, sembunyikan area chat-nya
            child: _currentSessionId == null
                ? const Center(
                    child: Text('👈 Pilih atau buat obrolan baru di sidebar'),
                  )
                : Column(
                    children: [
                      // 1. AREA TAMPILAN BALON CHAT
                      Expanded(
                        child: BlocBuilder<ChatBloc, ChatState>(
                          builder: (context, state) {
                            List<Widget> chatBubbles = state.messages
                                .map<Widget>((msg) {
                                  return ChatBubble(
                                    text: msg.content,
                                    isUser: msg.isUser,
                                  );
                                })
                                .toList();

                            if (state is ChatStreaming) {
                              chatBubbles.add(
                                ChatBubble(
                                  text: state.textSoFar,
                                  isUser: false,
                                ),
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
                                  child: Text(
                                    'Error: ${state.errorMessage}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              );
                            }

                            if (chatBubbles.isEmpty) {
                              return const Center(
                                child: Text(
                                  'Meja bersih. Silakan mulai ngobrol!',
                                ),
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
                                onSubmitted: (val) => _sendMessage(),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // 3. TOMBOL DINAMIS (Bisa Kirim, Bisa Stop)
                            BlocBuilder<ChatBloc, ChatState>(
                              builder: (context, state) {
                                // Cek apakah AI lagi ngetik?
                                bool isStreaming = state is ChatStreaming;

                                return FloatingActionButton(
                                  // Kalau lagi ngetik, tombol ini jadi rem. Kalau nggak, jadi pengirim pesan.
                                  onPressed: isStreaming
                                      ? () => context.read<ChatBloc>().add(
                                          StopGenerationEvent(),
                                        )
                                      : _sendMessage,
                                  backgroundColor: isStreaming
                                      ? Colors.red
                                      : Colors.teal,
                                  child: Icon(
                                    isStreaming ? Icons.stop : Icons.send,
                                    color: Colors.white,
                                  ),
                                );
                              },
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
    if (_textController.text.trim().isEmpty || _currentSessionId == null)
      return;

    context.read<ChatBloc>().add(
      SendMessageEvent(
        text: _textController.text,
        modelName: _currentModel,
        sessionId: _currentSessionId!,
      ),
    );

    // ✅ SURUH RESEPSIONIS REFRESH SIDEBAR SETELAH KIRIM PESAN
    context.read<SessionBloc>().add(LoadAllSessions());

    _textController.clear();
  }
}
