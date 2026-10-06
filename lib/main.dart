import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/biometric_service.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://SEU-PROJETO.supabase.co'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'SUA-CHAVE-ANON-AQUI'),
  );

  runApp(const FinanceApp());
}

class FinanceApp extends StatefulWidget {
  const FinanceApp({super.key});

  @override
  State<FinanceApp> createState() => _FinanceAppState();
}

class _FinanceAppState extends State<FinanceApp> {
  final _biometricService = BiometricService();
  bool _isAuthenticated = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      final available = await _biometricService.isBiometricAvailable();
      if (available) {
        final authenticated = await _biometricService.authenticate();
        setState(() {
          _isAuthenticated = authenticated;
          _isChecking = false;
        });
      } else {
        setState(() {
          _isAuthenticated = true;
          _isChecking = false;
        });
      }
    } else {
      setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    final familyId = session?.user.userMetadata?['family_id'] ?? 'SUA_FAMILIA_ID';

    if (_isChecking) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color(0xFF0F172A),
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: 'Controle Financeiro Familiar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: session != null
          ? (_isAuthenticated
              ? MainNavigationScreen(familyId: familyId)
              : Scaffold(
                  backgroundColor: const Color(0xFF0F172A),
                  body: Center(
                    child: ElevatedButton.icon(
                      onPressed: _checkBiometrics,
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('Desbloquear com Biometria'),
                    ),
                  ),
                ))
          : const LoginScreen(),
    );
  }
}
