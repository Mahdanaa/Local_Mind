import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../business_logic/session_bloc/session_bloc.dart';
import '../../business_logic/session_bloc/session_event.dart';
import '../../business_logic/session_bloc/session_state.dart';

class SidebarHistory extends StatelessWidget {
  final String? currentSessionId;
  final Function(String) onSessionSelected;

  const SidebarHistory({
    super.key,
    required this.currentSessionId,
    required this.onSessionSelected,
  });

  void _tampilkanFormPesanan(BuildContext context) {
    final promptController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Obrolan Baru',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: promptController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'System Prompt (Opsional)',
                  border: OutlineInputBorder(),

                  hintText: 'Misal: Kamu adalah programmer ahli Flutter...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);

                String finalPrompt = promptController.text.trim().isEmpty
                    ? 'Kamu adalah asisten AI yang pintar dan sangat membantu dalam bahasa Indonesia.'
                    : promptController.text.trim();

                context.read<SessionBloc>().add(
                  CreateNewSession(
                    title: 'Obrolan Baru',
                    systemPrompt: finalPrompt,
                  ),
                );

                Future.delayed(const Duration(milliseconds: 200), () {
                  if (!context.mounted) return;
                  final state = context.read<SessionBloc>().state;
                  if (state is SessionLoaded && state.sessions.isNotEmpty) {
                    onSessionSelected(state.sessions.first.id);
                  }
                });
              },
              child: const Text('Buat Chat'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          height: 80,
          width: double.infinity,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: SizedBox(
              width: 248,
              child: ElevatedButton.icon(
                onPressed: () {
                  _tampilkanFormPesanan(context);
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
          ),
        ),

        const Divider(height: 1),

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
                    final bool isSelected = session.id == currentSessionId;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: InkWell(
                        onTap: () => onSessionSelected(session.id),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.teal.withValues(alpha: 0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const NeverScrollableScrollPhysics(),
                            child: SizedBox(
                              width: 264,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 12.0,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected
                                          ? Icons.chat_bubble
                                          : Icons.chat_bubble_outline,
                                      color: isSelected
                                          ? Colors.teal
                                          : Colors.grey[600],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
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
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        context.read<SessionBloc>().add(
                                          DeleteSession(session.id),
                                        );
                                        if (isSelected) onSessionSelected('');
                                      },
                                      child: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.redAccent,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
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
