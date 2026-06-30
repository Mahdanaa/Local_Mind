import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../data/local_db/sqlite_helper.dart';
import '../../data/models/chat_session.dart';
import 'session_event.dart';
import 'session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();

  SessionBloc(this._dbHelper) : super(const SessionInitial()) {
    on<LoadAllSessions>((event, emit) async {
      emit(const SessionLoading());
      try {
        final List<ChatSession> sessions = await _dbHelper.getAllSessions();
        emit(SessionLoaded(sessions));
      } catch (e) {
        emit(SessionError(e.toString()));
      }
    });

    on<CreateNewSession>((event, emit) async {
      try {
        final ChatSession newSession = ChatSession(
          id: _uuid.v4(),
          title: event.title,
          systemPrompt: event.systemPrompt,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        );

        await _dbHelper.insertSession(newSession);

        add(const LoadAllSessions());
      } catch (e) {
        emit(SessionError(e.toString()));
      }
    });

    on<DeleteSession>((event, emit) async {
      await _dbHelper.deleteSession(event.sessionId);
      add(const LoadAllSessions());
    });

    on<RenameSession>((event, emit) async {
      await _dbHelper.updateSessionTitle(event.sessionId, event.newTitle);
      add(const LoadAllSessions());
    });
  }
}
