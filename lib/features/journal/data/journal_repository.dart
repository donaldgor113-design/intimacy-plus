import 'package:flutter/foundation.dart';
import '../models/journal_entry.dart';
import 'journal_database.dart';

/// Repository for Journal operations (with ChangeNotifier for Provider)
class JournalRepository extends ChangeNotifier {
  final JournalDatabase _db = JournalDatabase.instance;

  List<JournalEntry> _entries = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<JournalEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get count => _entries.length;

  /// Load all entries
  Future<void> loadEntries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _entries = await _db.getAllEntries();
    } catch (e) {
      _error = 'Помилка завантаження: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add new entry
  Future<bool> addEntry(JournalEntry entry) async {
    try {
      final id = await _db.insertEntry(entry);
      final newEntry = entry.copyWith(id: id);
      _entries.insert(0, newEntry);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Помилка створення: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// Update entry
  Future<bool> updateEntry(JournalEntry entry) async {
    try {
      await _db.updateEntry(entry);
      final index = _entries.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        _entries[index] = entry.copyWith(updatedAt: DateTime.now());
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Помилка оновлення: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// Delete entry
  Future<bool> deleteEntry(int id) async {
    try {
      await _db.deleteEntry(id);
      _entries.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Помилка видалення: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// Search entries
  Future<List<JournalEntry>> search(String query) async {
    if (query.isEmpty) return _entries;
    return await _db.searchEntries(query);
  }

  /// Get statistics
  Future<Map<String, dynamic>> getStats() async {
    final count = await _db.getEntriesCount();
    final now = DateTime.now();
    final thisMonth = _entries.where((e) =>
        e.createdAt.year == now.year && e.createdAt.month == now.month).length;
    final avgMood = _entries.isNotEmpty
        ? _entries.map((e) => e.mood).reduce((a, b) => a + b) / _entries.length
        : 0.0;

    return {
      'total': count,
      'thisMonth': thisMonth,
      'averageMood': avgMood.toStringAsFixed(1),
    };
  }
}
