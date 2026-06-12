import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../business_logic/session_bloc/session_bloc.dart';
import '../../business_logic/session_bloc/session_event.dart';
import '../../business_logic/session_bloc/session_state.dart';

class SidebarHistory extends StatelessWidget {
  final Function(String) onSessionSelected;

  const SidebarHistory({super.key, required this.onSessionSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Tombol Bikin Chat Baru (Sekarang Nampilin Popup)
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () =>
                _showSystemPromptDialog(context), // Panggil fungsi popup
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
                  itemCount: state.sessions.length,
                  itemBuilder: (context, index) {
                    final session = state.sessions[index];
                    return ListTile(
                      leading: const Icon(Icons.chat_bubble_outline),
                      title: Text(
                        session.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => onSessionSelected(session.id),
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

  // ==========================================
  // FUNGSI POPUP BUKU KARAKTER
  // ==========================================
  void _showSystemPromptDialog(BuildContext context) {
    final TextEditingController promptController = TextEditingController();

    // Nilai default biar user nggak wajib ngisi
    promptController.text =
        'Kamu adalah asisten AI yang pintar dan sangat membantu.';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Karakter AI (System Prompt)'),
          content: TextField(
            controller: promptController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Misal: Jawablah dengan gaya anak Jaksel...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext), // Batal
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                // Suruh resepsionis bikin sesi baru dengan karakter ini
                context.read<SessionBloc>().add(
                  CreateNewSession(
                    title: 'Obrolan Baru',
                    systemPrompt: promptController.text,
                  ),
                );
                Navigator.pop(dialogContext); // Tutup popup
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: const Text('Mulai Chat'), // INI DIA YANG TADI HILANG SOB!
            ),
          ],
        );
      },
    );
  }
}
