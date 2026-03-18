import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

enum ExperienceLevel {
  beginners('Тільки починаємо'),
  open('Відкриті до експериментів'),
  experienced('Досвідчені дослідники');

  const ExperienceLevel(this.label);
  final String label;
}

enum Goal {
  moreRomance('Більше романтики та ніжності'),
  addPassion('Додати пристрасті'),
  betterCommunication('Краще спілкуватися про бажання'),
  breakRoutine('Подолати рутину'),
  learnSafety('Дізнатися про безпеку та здоров\'я'),
  justCurious('Просто цікаво дослідити');

  const Goal(this.label);
  final String label;
}

enum ContentTone {
  soft('М\'який та романтичний'),
  playful('Грайливий та чуттєвий'),
  bold('Більш відвертий');

  const ContentTone(this.label);
  final String label;
}

class CoupleProfile {
  final String partner1Name;
  final String partner2Name;
  final ExperienceLevel experienceLevel;
  final Set<Goal> goals;
  final ContentTone tone;
  final int level;
  final int xp;
  final DateTime createdAt;

  CoupleProfile({
    required this.partner1Name,
    required this.partner2Name,
    required this.experienceLevel,
    this.goals = const {},
    required this.tone,
    this.level = 1,
    this.xp = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'partner1Name': partner1Name,
    'partner2Name': partner2Name,
    'experienceLevel': experienceLevel.name,
    'goals': goals.map((g) => g.name).toList(),
    'tone': tone.name,
    'level': level,
    'xp': xp,
    'createdAt': createdAt.toIso8601String(),
  };

  factory CoupleProfile.fromJson(Map<String, dynamic> json) => CoupleProfile(
    partner1Name: json['partner1Name'],
    partner2Name: json['partner2Name'],
    experienceLevel: ExperienceLevel.values.byName(json['experienceLevel']),
    goals: (json['goals'] as List).map((g) => Goal.values.byName(g)).toSet(),
    tone: ContentTone.values.byName(json['tone']),
    level: json['level'] ?? 1,
    xp: json['xp'] ?? 0,
    createdAt: DateTime.parse(json['createdAt']),
  );

  int get xpForNextLevel => level * 200;
  double get progressToNextLevel => xp / xpForNextLevel;

  String get levelTitle {
    switch (level) {
      case 1: return 'Перші кроки разом';
      case 2: return 'Відкриті серця';
      case 3: return 'Дослідники довіри';
      case 4: return 'Майстри комунікації';
      case 5: return 'Адепти чуттєвості';
      case 6: return 'Гармонійний дует';
      case 7: return 'Легенди близькості';
      default: return 'Легенди близькості';
    }
  }

  CoupleProfile copyWith({int? level, int? xp}) => CoupleProfile(
    partner1Name: partner1Name,
    partner2Name: partner2Name,
    experienceLevel: experienceLevel,
    goals: goals,
    tone: tone,
    level: level ?? this.level,
    xp: xp ?? this.xp,
    createdAt: createdAt,
  );

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('couple_profile', jsonEncode(toJson()));
    await prefs.setBool('onboarding_complete', true);
  }

  static Future<CoupleProfile?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('couple_profile');
    if (json == null) return null;
    return CoupleProfile.fromJson(jsonDecode(json));
  }

  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_complete') ?? false;
  }

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('couple_profile');
    await prefs.remove('onboarding_complete');
    await prefs.remove('pin_code');
    await prefs.remove('security_enabled');
  }
}
