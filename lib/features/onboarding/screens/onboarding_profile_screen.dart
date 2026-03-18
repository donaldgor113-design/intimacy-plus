import 'package:flutter/material.dart';
import '../models/couple_profile.dart';

class OnboardingProfileScreen extends StatefulWidget {
  final ExperienceLevel experienceLevel;
  final Set<Goal> goals;
  final ContentTone tone;
  final Function(CoupleProfile) onComplete;
  const OnboardingProfileScreen({super.key, required this.experienceLevel, required this.goals, required this.tone, required this.onComplete});

  @override
  State<OnboardingProfileScreen> createState() => _OnboardingProfileScreenState();
}

class _OnboardingProfileScreenState extends State<OnboardingProfileScreen> {
  final _name1Ctrl = TextEditingController();
  final _name2Ctrl = TextEditingController();

  @override
  void dispose() { _name1Ctrl.dispose(); _name2Ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text('Профіль пари',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('Давайте познайомимося',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 40),
              TextField(
                controller: _name1Ctrl,
                decoration: InputDecoration(
                  labelText: 'Ваше ім\'я / псевдонім',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  prefixIcon: const Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _name2Ctrl,
                decoration: InputDecoration(
                  labelText: 'Ім\'я партнера / псевдонім',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _name1Ctrl.text.isNotEmpty && _name2Ctrl.text.isNotEmpty
                    ? () {
                        final profile = CoupleProfile(
                          partner1Name: _name1Ctrl.text.trim(),
                          partner2Name: _name2Ctrl.text.trim(),
                          experienceLevel: widget.experienceLevel,
                          goals: widget.goals,
                          tone: widget.tone,
                        );
                        widget.onComplete(profile);
                      }
                    : null,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white, disabledBackgroundColor: Colors.grey.shade300, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text('Майже готово', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
