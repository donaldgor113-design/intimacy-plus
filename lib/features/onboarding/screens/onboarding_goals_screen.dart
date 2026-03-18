import 'package:flutter/material.dart';
import '../models/couple_profile.dart';

class OnboardingGoalsScreen extends StatefulWidget {
  final Function(Set<Goal>) onNext;
  const OnboardingGoalsScreen({super.key, required this.onNext});

  @override
  State<OnboardingGoalsScreen> createState() => _OnboardingGoalsScreenState();
}

class _OnboardingGoalsScreenState extends State<OnboardingGoalsScreen> {
  final Set<Goal> _selected = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text('Ваші цілі',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('Чому ви тут? (можна обрати кілька)',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 32),
              ...Goal.values.map((goal) => _option(goal)),
              const Spacer(),
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _selected.isEmpty ? null : () => widget.onNext(_selected),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white, disabledBackgroundColor: Colors.grey.shade300, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text('Продовжити', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _option(Goal goal) {
    final selected = _selected.contains(goal);
    return GestureDetector(
      onTap: () => setState(() {
        if (selected) { _selected.remove(goal); } else { _selected.add(goal); }
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? Colors.deepPurple.withOpacity(0.1) : Colors.grey.shade50,
          border: Border.all(color: selected ? Colors.deepPurple : Colors.grey.shade300, width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          Icon(selected ? Icons.check_box : Icons.check_box_outline_blank, color: selected ? Colors.deepPurple : Colors.grey),
          const SizedBox(width: 16),
          Expanded(child: Text(goal.label, style: TextStyle(fontSize: 15, fontWeight: selected ? FontWeight.w600 : FontWeight.normal, color: selected ? Colors.deepPurple : Colors.black87))),
        ]),
      ),
    );
  }
}
