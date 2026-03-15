import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/chat_message.dart';

class ChatDatabase {
  static Database? _db;
  static Future<Database> get db async => _db ??= await _init();

  static Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'chat.db');
    return await openDatabase(path, version: 1, onCreate: (db, _) async {
      await db.execute('''
        CREATE TABLE chat_messages (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          role TEXT NOT NULL,
          content TEXT NOT NULL,
          timestamp TEXT NOT NULL,
          isError INTEGER NOT NULL DEFAULT 0
        )
      ''');
    });
  }

  static Future<int> insert(ChatMessage m) async => await (await db).insert('chat_messages', m.toMap());
  static Future<List<ChatMessage>> getAll() async => (await (await db).query('chat_messages', orderBy: 'timestamp ASC')).map((m) => ChatMessage.fromMap(m)).toList();
  static Future<List<ChatMessage>> getLast(int n) async {
    final maps = await (await db).query('chat_messages', orderBy: 'timestamp DESC', limit: n);
    return maps.map((m) => ChatMessage.fromMap(m)).toList().reversed.toList();
  }
  static Future<void> clear() async => await (await db).delete('chat_messages');
  static Future<void> delete(int id) async => await (await db).delete('chat_messages', where: 'id = ?', whereArgs: [id]);
}
