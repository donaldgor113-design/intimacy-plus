import 'package:flutter/material.dart';

class OnboardingHowItWorksScreen extends StatelessWidget {
  const OnboardingHowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text('Як це працює',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              _item('🔥', 'Досліджуйте', 'Бібліотека сценаріїв та ідей для натхнення'),
              _item('🎲', 'Грайте', 'Ігри та генератори для легкості та інтриги'),
              _item('📚', 'Вчіться', 'Все про безпеку, здоров\'я та комунікацію'),
              _item('✨', 'Зростайте разом', 'Календар, досягнення та простір для бажань'),
              const Spacer(),
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/onboarding/experience'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text('Далі', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(String emoji, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          Text(desc, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ])),
      ]),
    );
  }
}
