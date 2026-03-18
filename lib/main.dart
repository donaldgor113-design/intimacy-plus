import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'features/journal/data/journal_repository.dart';
import 'features/journal/screens/journal_list_screen.dart';
import 'features/chat/data/chat_repository.dart';
import 'features/chat/screens/chat_screen.dart';
import 'features/onboarding/models/couple_profile.dart';
import 'features/onboarding/screens/onboarding_welcome_screen.dart';
import 'features/onboarding/screens/onboarding_how_it_works_screen.dart';
import 'features/onboarding/screens/onboarding_experience_screen.dart';
import 'features/onboarding/screens/onboarding_goals_screen.dart';
import 'features/onboarding/screens/onboarding_tone_screen.dart';
import 'features/onboarding/screens/onboarding_profile_screen.dart';
import 'features/onboarding/screens/onboarding_security_screen.dart';
import 'core/security/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const IntimacyPlusApp());
}

class IntimacyPlusApp extends StatelessWidget {
  const IntimacyPlusApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JournalRepository()),
        ChangeNotifierProvider(create: (_) => ChatRepository()),
      ],
      child: MaterialApp(
        title: 'Intimacy+',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const AuthGate(),
        routes: {
          '/onboarding/how': (_) => const OnboardingHowItWorksScreen(),
        },
      ),
    );
  }
}

/// Gate: checks if auth is needed, then routes to onboarding or home
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> with WidgetsBindingObserver {
  bool _checking = true;
  bool _authenticated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAuth();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _authenticated) {
      _checkAuth();
    }
  }

  Future<void> _checkAuth() async {
    final securityEnabled = await AuthService.isSecurityEnabled();
    if (!securityEnabled) {
      setState(() { _checking = false; _authenticated = true; });
      return;
    }
    final authenticated = await AuthService.authenticateWithBiometrics();
    setState(() { _checking = false; _authenticated = authenticated; });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!_authenticated) {
      return Scaffold(
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.lock, size: 64, color: Colors.deepPurple),
            const SizedBox(height: 24),
            const Text('Заблоковано', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _checkAuth, child: const Text('Розблокувати')),
          ]),
        ),
      );
    }
    return const OnboardingGate();
  }
}

/// Gate: checks if onboarding is complete
class OnboardingGate extends StatefulWidget {
  const OnboardingGate({super.key});
  @override
  State<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<OnboardingGate> {
  bool _loading = true;
  bool _complete = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final complete = await CoupleProfile.isOnboardingComplete();
    setState(() { _loading = false; _complete = complete; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (!_complete) return OnboardingFlow(onComplete: () => setState(() => _complete = true));
    return const HomeScreen();
  }
}

/// Onboarding flow with all 7 screens
class OnboardingFlow extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingFlow({super.key, required this.onComplete});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  int _step = 0;
  ExperienceLevel? _experience;
  Set<Goal> _goals = {};
  ContentTone? _tone;

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case 0: return OnboardingWelcomeScreen();
      case 1: return const OnboardingHowItWorksScreen();
      case 2: return OnboardingExperienceScreen(onNext: (level) => setState(() { _experience = level; _step = 3; }));
      case 3: return OnboardingGoalsScreen(onNext: (goals) => setState(() { _goals = goals; _step = 4; }));
      case 4: return OnboardingToneScreen(onNext: (tone) => setState(() { _tone = tone; _step = 5; }));
      case 5: return OnboardingProfileScreen(
        experienceLevel: _experience!, goals: _goals, tone: _tone!,
        onComplete: (profile) => Navigator.push(context, MaterialPageRoute(
          builder: (_) => OnboardingSecurityScreen(profile: profile, onComplete: widget.onComplete),
        )),
      );
      default: return const SizedBox();
    }
  }
}

/// Main Home Screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CoupleProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await CoupleProfile.load();
    setState(() => _profile = profile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intimacy+'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => _showProfile(),
          ),
        ],
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (_profile != null) ...[
            Text('Привіт, ${_profile!.partner1Name} та ${_profile!.partner2Name}! 💜',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Рівень ${_profile!.level}: ${_profile!.levelTitle}',
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: LinearProgressIndicator(
                value: _profile!.progressToNextLevel,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation(Colors.deepPurple),
              ),
            ),
            Text('${_profile!.xp}/${_profile!.xpForNextLevel} XP',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 40),
          ],
          _btn(context, Icons.book, '📔 Журнал', Colors.deepPurple, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JournalListScreen()))),
          const SizedBox(height: 12),
          _btn(context, Icons.chat, '🤖 AI Чат', Colors.green, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()))),
          const SizedBox(height: 12),
          _btn(context, Icons.school, '📚 Освіта', Colors.grey, () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Скоро')))),
          const SizedBox(height: 12),
          _btn(context, Icons.psychology, '🧠 Терапевт', Colors.grey, () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Скоро')))),
        ]),
      ),
    );
  }

  Widget _btn(BuildContext ctx, IconData icon, String title, Color color, VoidCallback onTap) {
    return Card(margin: const EdgeInsets.symmetric(horizontal: 24), child: ListTile(leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)), trailing: const Icon(Icons.chevron_right), onTap: onTap));
  }

  void _showProfile() {
    showModalBottomSheet(context: context, builder: (_) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_profile?.partner1Name ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text('& ${_profile?.partner2Name ?? ''}', style: const TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 16),
          Text('Рівень ${_profile?.level ?? 1}: ${_profile?.levelTitle ?? ''}'),
          Text('Досвід: ${_profile?.experienceLevel.label ?? ''}'),
          Text('Тон: ${_profile?.tone.label ?? ''}'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await CoupleProfile.reset();
              if (mounted) setState(() => _profile = null);
            },
            icon: const Icon(Icons.refresh), label: const Text('Скинути онбординг'),
            style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
          ),
          const SizedBox(height: 16),
        ]),
      );
    });
  }
}
