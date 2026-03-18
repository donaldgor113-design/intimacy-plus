import 'package:flutter/material.dart';
import '../models/couple_profile.dart';
import '../../../core/security/auth_service.dart';

class OnboardingSecurityScreen extends StatefulWidget {
  final CoupleProfile profile;
  final VoidCallback onComplete;
  const OnboardingSecurityScreen({super.key, required this.profile, required this.onComplete});

  @override
  State<OnboardingSecurityScreen> createState() => _OnboardingSecurityScreenState();
}

class _OnboardingSecurityScreenState extends State<OnboardingSecurityScreen> {
  bool _pinEnabled = false;
  bool _bioEnabled = false;
  bool _bioAvailable = false;
  String _pin = '';
  String _confirmPin = '';
  bool _confirming = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final available = await AuthService.isBiometricAvailable();
    setState(() => _bioAvailable = available);
  }

  void _onPinInput(String digit) {
    setState(() {
      if (_confirming) {
        _confirmPin += digit;
        if (_confirmPin.length == 4) {
          if (_pin == _confirmPin) {
            AuthService.savePin(_pin);
            _saveAndComplete();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN-коди не співпадають')));
            setState(() { _pin = ''; _confirmPin = ''; _confirming = false; });
          }
        }
      } else {
        _pin += digit;
        if (_pin.length == 4) {
          setState(() { _confirming = true; _confirmPin = ''; });
        }
      }
    });
  }

  void _onPinDelete() {
    setState(() {
      if (_confirming) {
        if (_confirmPin.isNotEmpty) _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
      } else {
        if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
      }
    });
  }

  Future<void> _saveAndComplete() async {
    await widget.profile.save();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    if (_pinEnabled) return _pinSetup();
    return _securityChoice();
  }

  Widget _securityChoice() {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.lock, size: 40, color: Colors.deepPurple),
              ),
              const SizedBox(height: 24),
              const Text('Ваша приватність — наш пріоритет',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('Дані зберігаються локально на пристрої.\nЗахистіть доступ до застосунку:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey, height: 1.5)),
              const SizedBox(height: 40),
              _securityOption(Icons.lock_outline, 'PIN-код', _pinEnabled, () => setState(() => _pinEnabled = true)),
              if (_bioAvailable) ...[
                const SizedBox(height: 12),
                _securityOption(Icons.fingerprint, 'Біометрія (Face ID / Fingerprint)', _bioEnabled, () async {
                  final ok = await AuthService.authenticateWithBiometrics(reason: 'Налаштувати біометрію для Intimacy+');
                  if (ok) {
                    await AuthService.savePin('bio');
                    _saveAndComplete();
                  }
                }),
              ],
              const SizedBox(height: 12),
              _securityOption(Icons.lock_open, 'Поки що без захисту', !_pinEnabled && !_bioEnabled, () => _saveAndComplete()),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _securityOption(IconData icon, String title, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? Colors.deepPurple.withOpacity(0.1) : Colors.grey.shade50,
          border: Border.all(color: selected ? Colors.deepPurple : Colors.grey.shade300, width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          Icon(icon, color: selected ? Colors.deepPurple : Colors.grey),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: TextStyle(fontSize: 16, fontWeight: selected ? FontWeight.w600 : FontWeight.normal, color: selected ? Colors.deepPurple : Colors.black87))),
        ]),
      ),
    );
  }

  Widget _pinSetup() {
    final current = _confirming ? _confirmPin : _pin;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(_confirming ? 'Підтвердіть PIN-код' : 'Створіть PIN-код',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('Введіть 4 цифри', style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 32),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(4, (i) =>
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 20, height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < current.length ? Colors.deepPurple : Colors.grey.shade300,
                  ),
                ),
              )),
              const SizedBox(height: 40),
              ...[
                ['1','2','3'],
                ['4','5','6'],
                ['7','8','9'],
                ['','0','⌫'],
              ].map((row) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: row.map((key) {
                  if (key.isEmpty) return const SizedBox(width: 80);
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: SizedBox(
                      width: 72, height: 72,
                      child: key == '⌫'
                        ? IconButton(onPressed: _onPinDelete, icon: const Icon(Icons.backspace_outlined, size: 28))
                        : TextButton(
                            onPressed: () => _onPinInput(key),
                            style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                            child: Text(key, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500)),
                          ),
                    ),
                  );
                }).toList(),
              )),
              const Spacer(),
              TextButton(onPressed: () => setState(() { _pinEnabled = false; _pin = ''; _confirmPin = ''; _confirming = false; }),
                child: const Text('Назад')),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
