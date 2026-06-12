import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../business_logic/session_bloc/session_bloc.dart';
import '../../business_logic/session_bloc/session_event.dart';
import '../../business_logic/session_bloc/session_state.dart';

class SidebarHistory extends StatelessWidget {
  final Function(String) onSessionSelected; // Fungsi saat history di-klik

  const SidebarHistory({super.key, required this.onSessionSelected});

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
              // Menyuruh resepsionis bikin sesi baru di database
              context.read<SessionBloc>().add(
                CreateNewSession(
                  title: 'Obrolan Baru',
                  systemPrompt: 'Kamu adalah asisten AI yang pintar.',
                ),
              );
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

                // Menampilkan daftar sesi dari yang terbaru
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
                      onTap: () => onSessionSelected(
                        session.id,
                      ), // Lapor ke layar utama!
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
