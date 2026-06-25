import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'local_mind.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sessions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        system_prompt TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        role TEXT NOT NULL,
        content TEXT NOT NULL,
        FOREIGN KEY (session_id) REFERENCES sessions (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> insertSession(ChatSession session) async {
    final db = await database;
    await db.insert(
      'sessions',
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ChatSession>> getAllSessions() async {
    final db = await database;
    final List<Map<String, Object?>> maps = await db.query(
      'sessions',
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => ChatSession.fromMap(map)).toList();
  }

  Future<void> insertMessage(ChatMessage message) async {
    final db = await database;
    await db.insert(
      'messages',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ChatMessage>> getMessagesBySession(String sessionId) async {
    final db = await database;
    final List<Map<String, Object?>> maps = await db.query(
      'messages',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'rowid ASC',
    );
    return maps.map((map) => ChatMessage.fromMap(map)).toList();
  }

  Future<void> updateSessionTitle(String sessionId, String newTitle) async {
    final db = await database;
    await db.update(
      'sessions',
      {'title': newTitle},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<ChatSession?> getSessionById(String sessionId) async {
    final db = await database;
    final maps = await db.query(
      'sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );

    if (maps.isNotEmpty) {
      return ChatSession.fromMap(maps.first);
    }
    return null;
  }

  Future<void> deleteSession(String sessionId) async {
    final db = await database;
    await db.delete(
      'messages',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
    await db.delete('sessions', where: 'id = ?', whereArgs: [sessionId]);
  }
}
