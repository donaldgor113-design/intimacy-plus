import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../data/chat_database.dart';
import '../services/ai_service.dart';

class ChatRepository extends ChangeNotifier {
  List<ChatMessage> _msgs = [];
  bool _loading = false;
  List<ChatMessage> get messages => _msgs;
  bool get loading => _loading;

  ChatRepository() { _load(); }

  Future<void> _load() async { _msgs = await ChatDatabase.getAll(); notifyListeners(); }

  Future<void> send(String txt) async {
    if (txt.trim().isEmpty) return;
    final user = ChatMessage(role: 'user', content: txt.trim());
    final uid = await ChatDatabase.insert(user);
    _msgs.add(ChatMessage(id: uid, role: 'user', content: txt.trim()));
    _loading = true; notifyListeners();

    try {
      final ctx = await ChatDatabase.getLast(20);
      final resp = await AiService.send(ctx);
      final ai = ChatMessage(role: 'assistant', content: resp);
      final aid = await ChatDatabase.insert(ai);
      _msgs.add(ChatMessage(id: aid, role: 'assistant', content: resp));
    } catch (e) {
      _msgs.add(ChatMessage(role: 'assistant', content: '❌ $e', isError: true));
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<void> clear() async { await ChatDatabase.clear(); _msgs.clear(); notifyListeners(); }
}
