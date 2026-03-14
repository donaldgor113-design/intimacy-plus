import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/journal/data/journal_repository.dart';
import 'features/journal/screens/journal_list_screen.dart';

void main() {
  runApp(const IntimacyPlusApp());
}

class IntimacyPlusApp extends StatelessWidget {
  const IntimacyPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JournalRepository()),
      ],
      child: MaterialApp(
        title: 'Intimacy+',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intimacy+'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Intimacy+',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Терапевтичний освітній додаток',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // Journal button
            _buildMenuButton(
              context,
              icon: Icons.book,
              title: '📔 Журнал',
              subtitle: 'Ваші записи та думки',
              color: Colors.deepPurple,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const JournalListScreen()),
              ),
            ),
            const SizedBox(height: 16),

            // Coming soon buttons
            _buildMenuButton(
              context,
              icon: Icons.chat,
              title: '🤖 AI Чат',
              subtitle: 'Незабаром',
              color: Colors.grey,
              onTap: () => _showComingSoon(context),
            ),
            const SizedBox(height: 16),

            _buildMenuButton(
              context,
              icon: Icons.school,
              title: '📚 Освіта',
              subtitle: 'Незабаром',
              color: Colors.grey,
              onTap: () => _showComingSoon(context),
            ),
            const SizedBox(height: 16),

            _buildMenuButton(
              context,
              icon: Icons.psychology,
              title: '🧠 Терапевт',
              subtitle: 'Незабаром',
              color: Colors.grey,
              onTap: () => _showComingSoon(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔜 Скоро буде доступно!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
