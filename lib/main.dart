import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/journal/data/journal_repository.dart';
import 'features/journal/screens/journal_list_screen.dart';
import 'features/chat/data/chat_repository.dart';
import 'features/chat/screens/chat_screen.dart';

void main() => runApp(const IntimacyPlusApp());

class IntimacyPlusApp extends StatelessWidget {
  const IntimacyPlusApp({super.key});
  @override Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => JournalRepository()),
      ChangeNotifierProvider(create: (_) => ChatRepository()),
    ], child: MaterialApp(title: 'Intimacy+', debugShowCheckedModeBanner: false, theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), useMaterial3: true), home: const HomeScreen()));
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Intimacy+'), backgroundColor: Theme.of(context).colorScheme.inversePrimary), body: Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('Intimacy+', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8), const Text('Терапевтичний освітній додаток', style: TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 40),
        _btn(context, Icons.book, '📔 Журнал', Colors.deepPurple, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JournalListScreen()))),
        const SizedBox(height: 16),
        _btn(context, Icons.chat, '🤖 AI Чат', Colors.green, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()))),
        const SizedBox(height: 16),
        _btn(context, Icons.school, '📚 Освіта', Colors.grey, () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Скоро')))),
        const SizedBox(height: 16),
        _btn(context, Icons.psychology, '🧠 Терапевт', Colors.grey, () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Скоро')))),
      ]),
    ));
  }

  Widget _btn(BuildContext ctx, IconData icon, String title, Color color, VoidCallback onTap) {
    return Card(margin: const EdgeInsets.symmetric(horizontal: 24), child: ListTile(leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)), trailing: const Icon(Icons.chevron_right), onTap: onTap));
  }
}
