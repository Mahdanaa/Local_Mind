import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../data/local_db/sqlite_helper.dart';
import '../../data/models/chat_session.dart';
import 'session_event.dart';
import 'session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();

  SessionBloc(this._dbHelper) : super(SessionInitial()) {
    // ATURAN 1: Kalau disuruh muat semua history
    on<LoadAllSessions>((event, emit) async {
      emit(SessionLoading());
      try {
        // Ambil data dari brankas
        final sessions = await _dbHelper.getAllSessions();
        emit(SessionLoaded(sessions)); // Kasih datanya ke UI Sidebar
      } catch (e) {
        emit(SessionError(e.toString()));
      }
    });

    // ATURAN 2: Kalau ada user nge-klik "New Chat"
    on<CreateNewSession>((event, emit) async {
      try {
        final newSession = ChatSession(
          id: _uuid.v4(),
          title: event.title,
          systemPrompt: event.systemPrompt,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        );

        // Simpan map folder baru ke brankas
        await _dbHelper.insertSession(newSession);

        // Setelah berhasil disimpan, otomatis panggil ATURAN 1
        // Biar sidebar-nya ke-refresh sendiri!
        add(LoadAllSessions());
      } catch (e) {
        emit(SessionError(e.toString()));
      }
    });
  }
}
