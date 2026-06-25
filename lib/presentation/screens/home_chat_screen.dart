import 'dart:convert';
import 'package:http/http.dart' as http;
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
  final FocusNode _messageFocusNode = FocusNode();

  String? _currentSessionId;
  double _sidebarWidth = 280.0;
  String _currentModel = '';
  List<String> _availableModels = [];
  bool _isLoadingModels = true;

  @override
  void initState() {
    super.initState();
    _fetchLocalModels();
  }

  @override
  void dispose() {
    _textController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchLocalModels() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:11434/api/tags'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> models = data['models'];

        if (mounted) {
          setState(() {
            _availableModels = models.map((m) => m['name'].toString()).toList();
            if (_availableModels.isNotEmpty) {
              _currentModel = _availableModels.first;
            }
            _isLoadingModels = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _availableModels = [];
          _isLoadingModels = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: _sidebarWidth,
            color: Colors.grey[50],
            child: ClipRect(
              child: _sidebarWidth > 0
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16.0,
                            top: 16.0,
                            bottom: 8.0,
                            right: 12.0,
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const NeverScrollableScrollPhysics(),
                            child: SizedBox(
                              width: 250 - 28.0,
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/logo.png',
                                    width: 28,
                                    height: 28,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'LocalMind',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.menu_open,
                                      color: Colors.grey,
                                    ),
                                    tooltip: 'Tutup Sidebar',
                                    onPressed: () {
                                      setState(() {
                                        _sidebarWidth = 0.0;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        Expanded(
                          child: SidebarHistory(
                            currentSessionId: _currentSessionId,
                            onSessionSelected: (String sessionId) {
                              setState(() {
                                _currentSessionId = sessionId;
                              });
                              context.read<ChatBloc>().add(
                                LoadChatHistory(sessionId),
                              );
                              _messageFocusNode.requestFocus();
                            },
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
            ),
          ),

          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (_sidebarWidth == 0) ...[
                        IconButton(
                          icon: Image.asset(
                            'assets/images/logo.png',
                            width: 28,
                            height: 28,
                            fit: BoxFit.contain,
                          ),
                          tooltip: 'Buka Sidebar',
                          onPressed: () {
                            setState(() {
                              _sidebarWidth = 280.0;
                            });
                          },
                        ),
                      ] else ...[
                        const Icon(Icons.smart_toy, color: Colors.teal),
                        const SizedBox(width: 8),
                        const Text(
                          'Model AI: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        _isLoadingModels
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : _availableModels.isEmpty
                            ? const Text(
                                'Ollama Mati / Kosong!',
                                style: TextStyle(color: Colors.red),
                              )
                            : DropdownButton<String>(
                                value: _currentModel,
                                underline: const SizedBox(),
                                items: _availableModels.map((String model) {
                                  return DropdownMenuItem<String>(
                                    value: model,
                                    child: Text(model),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _currentModel = newValue;
                                    });
                                  }
                                },
                              ),
                      ],
                    ],
                  ),
                ),

                Expanded(
                  child: _currentSessionId == null
                      ? const Center(
                          child: Text(
                            '👈 Buka sidebar dan pilih/buat obrolan baru',
                          ),
                        )
                      : Column(
                          children: [
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
                                          style: const TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  if (chatBubbles.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        'Mulai obrolan dengan mengetik di bawah!',
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

                            Container(
                              padding: const EdgeInsets.all(16),
                              color: Colors.white,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _textController,
                                      focusNode: _messageFocusNode,
                                      decoration: const InputDecoration(
                                        hintText:
                                            'Tanya sesuatu ke AI lokal...',
                                        border: OutlineInputBorder(),
                                      ),
                                      onSubmitted: (val) => _sendMessage(),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  BlocBuilder<ChatBloc, ChatState>(
                                    builder: (context, state) {
                                      bool isBusy =
                                          state is ChatStreaming ||
                                          state is ChatLoading;
                                      return FloatingActionButton(
                                        onPressed: isBusy
                                            ? () => context
                                                  .read<ChatBloc>()
                                                  .add(StopGenerationEvent())
                                            : _sendMessage,
                                        backgroundColor: isBusy
                                            ? Colors.red
                                            : Colors.teal,
                                        child: Icon(
                                          isBusy ? Icons.stop : Icons.send,
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
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_textController.text.trim().isEmpty || _currentSessionId == null) {
      return;
    }

    final String userMessage = _textController.text.trim();

    final chatState = context.read<ChatBloc>().state;
    if (chatState.messages.isEmpty) {
      String newTitle = userMessage.length > 25
          ? '${userMessage.substring(0, 25)}...'
          : userMessage;

      context.read<SessionBloc>().add(
        RenameSession(sessionId: _currentSessionId!, newTitle: newTitle),
      );
    }

    context.read<ChatBloc>().add(
      SendMessageEvent(
        text: userMessage,
        modelName: _currentModel,
        sessionId: _currentSessionId!,
      ),
    );

    context.read<SessionBloc>().add(LoadAllSessions());
    _textController.clear();

    _messageFocusNode.requestFocus();
  }
}
