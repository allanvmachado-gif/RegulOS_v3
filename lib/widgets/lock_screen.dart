// ═══════════════════════════════════════════════════════════
//  lock_screen.dart
// ═══════════════════════════════════════════════════════════
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../theme/app_theme.dart';

class LockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  const LockScreen({super.key, required this.onUnlocked});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final box = Hive.box('config');
  String _input = '';
  bool _isPassword = false;
  bool _showPassword = false;
  String _error = '';
  int _tentativas = 0;
  bool _bloqueado = false;
  final _pwController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final lockType = box.get('lockType', defaultValue: 'pin') as String;
    _isPassword = lockType == 'password';
  }

  String _hash(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }

  void _verificar(String value) {
    if (_bloqueado) return;
    final stored = box.get('lockHash', defaultValue: '') as String;
    if (_hash(value) == stored) {
      widget.onUnlocked();
    } else {
      _tentativas++;
      if (_tentativas >= 5) {
        setState(() {
          _bloqueado = true;
          _error = 'Muitas tentativas. Aguarde 5 minutos.';
        });
        Future.delayed(const Duration(minutes: 5), () {
          if (mounted) setState(() { _bloqueado = false; _tentativas = 0; });
        });
      } else {
        setState(() {
          _error = 'Senha incorreta (${5 - _tentativas} tentativas restantes)';
          _input = '';
          _pwController.clear();
        });
      }
    }
  }

  void _digitoPin(String d) {
    if (_input.length >= 6 || _bloqueado) return;
    setState(() { _input += d; _error = ''; });
    if (_input.length == 6) {
      Future.delayed(const Duration(milliseconds: 150), () => _verificar(_input));
    }
  }

  void _apagarPin() {
    if (_input.isEmpty) return;
    setState(() => _input = _input.substring(0, _input.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícone
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_rounded,
                      color: AppTheme.accentLight, size: 40),
                ),
                const SizedBox(height: 24),
                Text('Agenda Allan',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.text, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(_isPassword ? 'Digite sua senha' : 'Digite seu PIN de 6 dígitos',
                    style: const TextStyle(color: AppTheme.textMuted)),
                const SizedBox(height: 40),

                if (_isPassword) _buildSenhaInput() else _buildPinInput(),

                if (_error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(_error,
                        style: const TextStyle(color: AppTheme.red),
                        textAlign: TextAlign.center),
                  ),

                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => setState(() {
                    _isPassword = !_isPassword;
                    _input = '';
                    _error = '';
                    _pwController.clear();
                  }),
                  child: Text(_isPassword ? 'Usar PIN' : 'Usar senha',
                      style: const TextStyle(color: AppTheme.accentLight)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinInput() {
    return Column(
      children: [
        // Pontos
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (i) {
            final filled = i < _input.length;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 16, height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? AppTheme.accent : AppTheme.divider,
                border: Border.all(
                  color: filled ? AppTheme.accent : AppTheme.textMuted,
                  width: 1.5,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 32),
        // Teclado numérico
        _buildTeclado(),
      ],
    );
  }

  Widget _buildTeclado() {
    final btns = ['1','2','3','4','5','6','7','8','9','','0','⌫'];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.6,
      children: btns.map((b) {
        if (b.isEmpty) return const SizedBox();
        return InkWell(
          onTap: () => b == '⌫' ? _apagarPin() : _digitoPin(b),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Center(
              child: b == '⌫'
                  ? const Icon(Icons.backspace_outlined,
                      color: AppTheme.textMuted, size: 22)
                  : Text(b, style: const TextStyle(
                      color: AppTheme.text, fontSize: 22, fontWeight: FontWeight.w500)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSenhaInput() {
    return Column(
      children: [
        TextField(
          controller: _pwController,
          obscureText: !_showPassword,
          autofocus: true,
          style: const TextStyle(color: AppTheme.text),
          decoration: InputDecoration(
            hintText: 'Senha',
            suffixIcon: IconButton(
              icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility,
                  color: AppTheme.textMuted),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
          ),
          onSubmitted: (v) => _verificar(v),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _verificar(_pwController.text),
          child: const Text('Entrar'),
        ),
      ],
    );
  }
}
