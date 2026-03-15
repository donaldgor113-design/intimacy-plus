import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/chat_repository.dart';
import '../widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();

  @override void dispose() { _ctrl.dispose(); _scroll.dispose(); super.dispose(); }

  void _send() {
    final txt = _ctrl.text.trim();
    if (txt.isEmpty) return;
    _ctrl.clear();
    context.read<ChatRepository>().send(txt);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  void _clear() {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Очистити чат?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Скасувати')),
        TextButton(onPressed: () { context.read<ChatRepository>().clear(); Navigator.pop(context); }, style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Очистити')),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🤖 AI Чат'), actions: [IconButton(icon: const Icon(Icons.delete_outline), onPressed: _clear, tooltip: 'Очистити чат')]),
      body: Column(children: [
        Expanded(child: Consumer<ChatRepository>(builder: (_, repo, __) {
          if (repo.messages.isEmpty) return const Center(child: Text('Почаctomy розмову...'));
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
          return ListView.builder(controller: _scroll, padding: const EdgeInsets.all(8), itemCount: repo.messages.length + (repo.loading ? 1 : 0), itemBuilder: (_, i) {
            if (i == repo.messages.length) return const Padding(padding: EdgeInsets.all(8), child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))));
            return ChatBubble(message: repo.messages[i]);
          });
        })),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(children: [
            Expanded(child: TextField(controller: _ctrl, decoration: const InputDecoration(hintText: 'Напишіть...', border: OutlineInputBorder(), contentPadding: EdgeInsets.all(12)), textInputAction: TextInputAction.send, onSubmitted: (_) => _send())),
            const SizedBox(width: 8),
            Consumer<ChatRepository>(builder: (_, repo, __) => FloatingActionButton(onPressed: repo.loading ? null : _send, mini: true, child: const Icon(Icons.send))),
          ]),
        ),
      ]),
    );
  }
}
