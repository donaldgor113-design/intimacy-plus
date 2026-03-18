import 'package:flutter/material.dart';
import '../models/couple_profile.dart';

class OnboardingExperienceScreen extends StatefulWidget {
  final Function(ExperienceLevel) onNext;
  const OnboardingExperienceScreen({super.key, required this.onNext});

  @override
  State<OnboardingExperienceScreen> createState() => _OnboardingExperienceScreenState();
}

class _OnboardingExperienceScreenState extends State<OnboardingExperienceScreen> {
  ExperienceLevel? _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text('Ваш рівень досвіду',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('Оберіть, що найближче до вас',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 32),
              ...ExperienceLevel.values.map((level) => _option(level)),
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

  Widget _option(ExperienceLevel level) {
    final selected = _selected == level;
    return GestureDetector(
      onTap: () => setState(() => _selected = level),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? Colors.deepPurple.withOpacity(0.1) : Colors.grey.shade50,
          border: Border.all(color: selected ? Colors.deepPurple : Colors.grey.shade300, width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          Icon(selected ? Icons.check_circle : Icons.circle_outlined, color: selected ? Colors.deepPurple : Colors.grey),
          const SizedBox(width: 16),
          Expanded(child: Text(level.label, style: TextStyle(fontSize: 16, fontWeight: selected ? FontWeight.w600 : FontWeight.normal, color: selected ? Colors.deepPurple : Colors.black87))),
        ]),
      ),
    );
  }
}
