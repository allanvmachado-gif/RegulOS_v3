// ═══════════════════════════════════════════════════════════
//  login_screen.dart
// ═══════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;
  String _erro = '';

  Future<void> _login() async {
    setState(() { _loading = true; _erro = ''; });
    try {
      await context.read<AppState>().signInWithGoogle();
    } catch (e) {
      setState(() => _erro = 'Erro ao entrar. Tente novamente.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo / ícone
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.accent.withOpacity(0.3), width: 2),
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: AppTheme.accentLight, size: 48),
              ),
              const SizedBox(height: 32),
              Text('Agenda Allan',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppTheme.text, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Sua agenda inteligente com gamificação RPG',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                  textAlign: TextAlign.center),
              const SizedBox(height: 48),

              // Benefícios
              _benefitRow(Icons.sync_rounded, 'Sincroniza entre celular e computador'),
              _benefitRow(Icons.cloud_done_rounded, 'Dados salvos na nuvem'),
              _benefitRow(Icons.lock_rounded, 'Seus dados são privados'),
              _benefitRow(Icons.bolt_rounded, 'Sistema de XP e níveis RPG'),
              const SizedBox(height: 40),

              // Botão Google
              _loading
                  ? const CircularProgressIndicator(color: AppTheme.accent)
                  : SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: _GoogleIcon(),
                        label: const Text('Entrar com Google',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        onPressed: _login,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.text,
                          side: const BorderSide(color: AppTheme.divider, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),

              if (_erro.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(_erro,
                      style: const TextStyle(color: AppTheme.red),
                      textAlign: TextAlign.center),
                ),

              const SizedBox(height: 24),
              const Text('Gratuito · Sem anúncios · Dados só seus',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _benefitRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accentLight, size: 18),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: AppTheme.textMuted, fontSize: 14)),
        ],
      ),
    );
  }
}

// Ícone Google em SVG manual (sem dependência externa)
class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22, height: 22,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(
        child: Text('G',
            style: TextStyle(color: Color(0xFF4285F4),
                fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }
}
