import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatBubble({super.key, required this.message});
  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(padding: EdgeInsets.only(left: isUser ? 48 : 8, right: isUser ? 8 : 48, top: 4, bottom: 4), child: Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isUser) ...[CircleAvatar(radius: 16, backgroundColor: Colors.deepPurple.shade100, child: const Icon(Icons.smart_toy, size: 18, color: Colors.deepPurple)), const SizedBox(width: 8)],
        Flexible(child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: BoxDecoration(color: isUser ? Colors.deepPurple : Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.only(topLeft: const Radius.circular(16), topRight: const Radius.circular(16), bottomLeft: Radius.circular(isUser ? 16 : 4), bottomRight: Radius.circular(isUser ? 4 : 16))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(message.content, style: TextStyle(color: isUser ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant)), const SizedBox(height: 4), Text('${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}', style: TextStyle(fontSize: 11, color: isUser ? Colors.white70 : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6)))]))),
        if (isUser) ...[const SizedBox(width: 8), CircleAvatar(radius: 16, backgroundColor: Colors.blue.shade100, child: Icon(Icons.person, size: 18, color: Colors.blue))],
      ],
    ));
  }
}
