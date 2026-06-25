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
    on<LoadAllSessions>((event, emit) async {
      emit(SessionLoading());
      try {
        final sessions = await _dbHelper.getAllSessions();
        emit(SessionLoaded(sessions));
      } catch (e) {
        emit(SessionError(e.toString()));
      }
    });

    on<CreateNewSession>((event, emit) async {
      try {
        final newSession = ChatSession(
          id: _uuid.v4(),
          title: event.title,
          systemPrompt: event.systemPrompt,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        );

        await _dbHelper.insertSession(newSession);

        add(LoadAllSessions());
      } catch (e) {
        emit(SessionError(e.toString()));
      }
    });
    on<DeleteSession>((event, emit) async {
      await _dbHelper.deleteSession(event.sessionId);
      add(LoadAllSessions());
    });
    on<RenameSession>((event, emit) async {
      await _dbHelper.updateSessionTitle(event.sessionId, event.newTitle);
      add(LoadAllSessions());
    });
  }
}

class DeleteSession extends SessionEvent {
  final String sessionId;
  DeleteSession(this.sessionId);
}
