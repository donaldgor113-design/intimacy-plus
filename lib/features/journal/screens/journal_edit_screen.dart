import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/journal_repository.dart';
import '../models/journal_entry.dart';

/// Journal edit/create screen
class JournalEditScreen extends StatefulWidget {
  final JournalEntry? entry;

  const JournalEditScreen({super.key, this.entry});

  @override
  State<JournalEditScreen> createState() => _JournalEditScreenState();
}

class _JournalEditScreenState extends State<JournalEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;
  int _mood = 3;
  bool _isSaving = false;

  bool get isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?.title ?? '');
    _contentController =
        TextEditingController(text: widget.entry?.content ?? '');
    _tagsController = TextEditingController(text: widget.entry?.tags ?? '');
    _mood = widget.entry?.mood ?? 3;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '✏️ Редагувати' : '📝 Новий запис'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteEntry,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Заголовок',
                  hintText: 'Наприклад: Гарний день',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введіть заголовок';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Mood selector
              const Text('Настрій:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) {
                  final moodValue = index + 1;
                  final emojis = ['😢', '😕', '😐', '🙂', '😊'];
                  final labels = [
                    'Дуже погано',
                    'Погано',
                    'Нормально',
                    'Добре',
                    'Відмінно'
                  ];
                  final isSelected = _mood == moodValue;

                  return GestureDetector(
                    onTap: () => setState(() => _mood = moodValue),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context)
                                .colorScheme
                                .primaryContainer
                            : null,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(emojis[index],
                              style: const TextStyle(fontSize: 28)),
                          const SizedBox(height: 4),
                          Text(labels[index],
                              style: const TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Content
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Зміст',
                  hintText: 'Опишіть ваш день, думки, почуття...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit_note),
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введіть зміст';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Tags
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Теги (через кому)',
                  hintText: 'наприклад: здоров\'я, стосунки, робота',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.tag),
                ),
                textCapitalization: TextCapitalization.none,
              ),
              const SizedBox(height: 24),

              // Save button
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveEntry,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_isSaving ? 'Збереження...' : 'Зберегти'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Save entry
  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final repo = context.read<JournalRepository>();

    final entry = JournalEntry(
      id: widget.entry?.id,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      mood: _mood,
      tags: _tagsController.text.trim().isNotEmpty
          ? _tagsController.text.trim()
          : null,
      createdAt: widget.entry?.createdAt,
    );

    bool success;
    if (isEditing) {
      success = await repo.updateEntry(entry);
    } else {
      success = await repo.addEntry(entry);
    }

    setState(() => _isSaving = false);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Запис оновлено ✅' : 'Запис створено ✅'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Помилка збереження ❌'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Delete entry
  Future<void> _deleteEntry() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Видалити запис?'),
        content: const Text('Цю дію неможливо скасувати.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Скасувати'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Видалити', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final repo = context.read<JournalRepository>();
    final success = await repo.deleteEntry(widget.entry!.id!);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Запис видалено 🗑️'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}
