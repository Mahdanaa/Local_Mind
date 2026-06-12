import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../business_logic/session_bloc/session_bloc.dart';
import '../../business_logic/session_bloc/session_event.dart';
import '../../business_logic/session_bloc/session_state.dart';

class SidebarHistory extends StatelessWidget {
  final String? currentSessionId; // ✅ MODIFIKASI: Tahu meja mana yang aktif
  final Function(String) onSessionSelected;

  const SidebarHistory({
    super.key,
    required this.currentSessionId, // ✅ Wajib diisi dari layar utama
    required this.onSessionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Tombol Bikin Chat Baru
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              context.read<SessionBloc>().add(
                CreateNewSession(
                  title: 'Obrolan Baru',
                  systemPrompt:
                      'Kamu adalah asisten AI yang pintar dan sangat membantu.',
                ),
              );

              Future.delayed(const Duration(milliseconds: 200), () {
                final state = context.read<SessionBloc>().state;
                if (state is SessionLoaded && state.sessions.isNotEmpty) {
                  onSessionSelected(state.sessions.first.id);
                }
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('New Chat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),

        const Divider(height: 1),

        // 2. Daftar Riwayat Chat (Buku Tamu)
        Expanded(
          child: BlocBuilder<SessionBloc, SessionState>(
            builder: (context, state) {
              if (state is SessionLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is SessionLoaded) {
                if (state.sessions.isEmpty) {
                  return const Center(child: Text('Belum ada riwayat.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  itemCount: state.sessions.length,
                  itemBuilder: (context, index) {
                    final session = state.sessions[index];

                    // ✅ MODIFIKASI LOGIKA: Cek apakah item ini yang lagi dipilih?
                    final bool isSelected = session.id == currentSessionId;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: ListTile(
                        // Kasih background warna blok teal tipis kalau dipilih
                        tileColor: isSelected
                            ? Colors.teal.withOpacity(0.12)
                            : null,
                        // Bikin sudut blok-nya agak melengkung biar aesthetic mirip Notion/ChatGPT
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        // Icon-nya ikutan berubah warna dan bentuk
                        leading: Icon(
                          isSelected
                              ? Icons.chat_bubble
                              : Icons.chat_bubble_outline,
                          color: isSelected ? Colors.teal : Colors.grey[600],
                        ),
                        // Judul teksnya ditebalkan kalau aktif
                        title: Text(
                          session.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Colors.teal[800]
                                : Colors.black87,
                          ),
                        ),
                        onTap: () => onSessionSelected(session.id),
                      ),
                    );
                  },
                );
              } else if (state is SessionError) {
                return Center(child: Text('Error: ${state.message}'));
              }

              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }
}
