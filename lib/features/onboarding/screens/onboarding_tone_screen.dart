import 'package:flutter/material.dart';
import '../models/couple_profile.dart';

class OnboardingToneScreen extends StatefulWidget {
  final Function(ContentTone) onNext;
  const OnboardingToneScreen({super.key, required this.onNext});

  @override
  State<OnboardingToneScreen> createState() => _OnboardingToneScreenState();
}

class _OnboardingToneScreenState extends State<OnboardingToneScreen> {
  ContentTone? _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text('Налаштування тону',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('Який тон контенту вам комфортніший?',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 32),
              ...ContentTone.values.map((tone) => _option(tone)),
              const Spacer(),
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _selected == null ? null : () => widget.onNext(_selected!),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white, disabledBackgroundColor: Colors.grey.shade300, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
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

  Widget _option(ContentTone tone) {
    final selected = _selected == tone;
    String subtitle;
    switch (tone) {
      case ContentTone.soft:
        subtitle = 'Акцент на ніжності, довірі, емоційному зв\'язку';
      case ContentTone.playful:
        subtitle = 'Баланс між романтикою та сміливістю';
      case ContentTone.bold:
        subtitle = 'Прямі рекомендації, менше евфемізмів';
    }
    return GestureDetector(
      onTap: () => setState(() => _selected = tone),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? Colors.deepPurple.withOpacity(0.1) : Colors.grey.shade50,
          border: Border.all(color: selected ? Colors.deepPurple : Colors.grey.shade300, width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(selected ? Icons.check_circle : Icons.circle_outlined, color: selected ? Colors.deepPurple : Colors.grey),
            const SizedBox(width: 16),
            Text(tone.label, style: TextStyle(fontSize: 16, fontWeight: selected ? FontWeight.w600 : FontWeight.normal, color: selected ? Colors.deepPurple : Colors.black87)),
          ]),
          Padding(padding: const EdgeInsets.only(left: 40, top: 4), child: Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey))),
        ]),
      ),
    );
  }
}
