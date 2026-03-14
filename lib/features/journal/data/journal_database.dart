import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/journal_entry.dart';

/// SQLite database helper for Journal
class JournalDatabase {
  static final JournalDatabase instance = JournalDatabase._init();
  static Database? _database;

  JournalDatabase._init();

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('journal.db');
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// Create tables
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE journal_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        mood INTEGER NOT NULL DEFAULT 3,
        tags TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Index for faster queries
    await db.execute('''
      CREATE INDEX idx_journal_created_at ON journal_entries(created_at)
    ''');
  }

  // ==================== CRUD OPERATIONS ====================

  /// CREATE — Insert new entry
  Future<int> insertEntry(JournalEntry entry) async {
    final db = await database;
    return await db.insert('journal_entries', entry.toMap());
  }

  /// READ — Get all entries (newest first)
  Future<List<JournalEntry>> getAllEntries() async {
    final db = await database;
    final maps = await db.query(
      'journal_entries',
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => JournalEntry.fromMap(map)).toList();
  }

  /// READ — Get single entry by ID
  Future<JournalEntry?> getEntryById(int id) async {
    final db = await database;
    final maps = await db.query(
      'journal_entries',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return JournalEntry.fromMap(maps.first);
  }

  /// READ — Search entries by title or content
  Future<List<JournalEntry>> searchEntries(String query) async {
    final db = await database;
    final maps = await db.query(
      'journal_entries',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => JournalEntry.fromMap(map)).toList();
  }

  /// READ — Get entries by mood
  Future<List<JournalEntry>> getEntriesByMood(int mood) async {
    final db = await database;
    final maps = await db.query(
      'journal_entries',
      where: 'mood = ?',
      whereArgs: [mood],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => JournalEntry.fromMap(map)).toList();
  }

  /// READ — Get entries count
  Future<int> getEntriesCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM journal_entries');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// UPDATE — Update existing entry
  Future<int> updateEntry(JournalEntry entry) async {
    final db = await database;
    return await db.update(
      'journal_entries',
      entry.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  /// DELETE — Delete entry by ID
  Future<int> deleteEntry(int id) async {
    final db = await database;
    return await db.delete(
      'journal_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// DELETE — Delete all entries
  Future<int> deleteAllEntries() async {
    final db = await database;
    return await db.delete('journal_entries');
  }

  /// Close database
  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}
