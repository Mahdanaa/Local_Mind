import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/local_db/sqlite_helper.dart';
import 'data/repositories/ollama_repository_impl.dart';
import 'business_logic/chat_bloc/chat_bloc.dart';
import 'business_logic/session_bloc/session_bloc.dart';
import 'business_logic/session_bloc/session_event.dart';
import 'presentation/screens/home_chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbHelper = DatabaseHelper();
  final llmRepository = OllamaRepositoryImpl();

  runApp(MyApp(dbHelper: dbHelper, llmRepository: llmRepository));
}

class MyApp extends StatelessWidget {
  final DatabaseHelper dbHelper;
  final OllamaRepositoryImpl llmRepository;

  const MyApp({super.key, required this.dbHelper, required this.llmRepository});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SessionBloc(dbHelper)..add(LoadAllSessions()),
        ),
        BlocProvider(create: (context) => ChatBloc(llmRepository, dbHelper)),
      ],
      child: MaterialApp(
        title: 'LocalMind',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const HomeChatScreen(),
      ),
    );
  }
}
