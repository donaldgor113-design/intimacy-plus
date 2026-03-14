import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/journal_repository.dart';
import '../models/journal_entry.dart';
import 'journal_edit_screen.dart';

/// Journal list screen with entries
class JournalListScreen extends StatefulWidget {
  const JournalListScreen({super.key});

  @override
  State<JournalListScreen> createState() => _JournalListScreenState();
}

class _JournalListScreenState extends State<JournalListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JournalRepository>().loadEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📔 Журнал'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearch,
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: _showStats,
          ),
        ],
      ),
      body: Consumer<JournalRepository>(
        builder: (context, repo, child) {
          if (repo.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (repo.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(repo.error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => repo.loadEntries(),
                    child: const Text('Повторити'),
                  ),
                ],
              ),
            );
          }

          if (repo.entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.book_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Журнал порожній',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Натисніть + щоб створити перший запис',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => repo.loadEntries(),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: repo.entries.length,
              itemBuilder: (context, index) {
                final entry = repo.entries[index];
                return _buildEntryCard(context, entry, repo);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Build entry card
  Widget _buildEntryCard(
      BuildContext context, JournalEntry entry, JournalRepository repo) {
    final moodEmojis = ['😢', '😕', '😐', '🙂', '😊'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: ListTile(
        leading: Text(
          moodEmojis[entry.mood - 1],
          style: const TextStyle(fontSize: 28),
        ),
        title: Text(
          entry.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(entry.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _openEditor(context, entry: entry);
            } else if (value == 'delete') {
              _confirmDelete(context, entry, repo);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('✏️ Редагувати')),
            const PopupMenuItem(value: 'delete', child: Text('🗑️ Видалити')),
          ],
        ),
        onTap: () => _openEditor(context, entry: entry),
      ),
    );
  }

  /// Open editor screen
  void _openEditor(BuildContext context, {JournalEntry? entry}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JournalEditScreen(entry: entry),
      ),
    );
  }

  /// Confirm delete dialog
  void _confirmDelete(
      BuildContext context, JournalEntry entry, JournalRepository repo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Видалити запис?'),
        content: Text('Ви впевнені, що хочете видалити "${entry.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Скасувати'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              repo.deleteEntry(entry.id!);
            },
            child: const Text('Видалити', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Show search dialog
  void _showSearch() {
    showSearch(
      context: context,
      delegate: _JournalSearchDelegate(
        repository: context.read<JournalRepository>(),
      ),
    );
  }

  /// Show statistics dialog
  void _showStats() async {
    final repo = context.read<JournalRepository>();
    final stats = await repo.getStats();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('📊 Статистика'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Всього записів: ${stats['total']}'),
            Text('Цього місяця: ${stats['thisMonth']}'),
            Text('Середній настрій: ${stats['averageMood']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Format date
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

/// Search delegate for journal
class _JournalSearchDelegate extends SearchDelegate {
  final JournalRepository repository;

  _JournalSearchDelegate({required this.repository});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  Widget _buildSearchResults() {
    return FutureBuilder<List<JournalEntry>>(
      future: repository.search(query),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final results = snapshot.data!;
        if (results.isEmpty) {
          return const Center(child: Text('Нічого не знайдено'));
        }
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final entry = results[index];
            return ListTile(
              title: Text(entry.title),
              subtitle: Text(entry.content, maxLines: 2),
              onTap: () => close(context, entry),
            );
          },
        );
      },
    );
  }
}
