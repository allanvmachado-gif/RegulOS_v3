// ═══════════════════════════════════════════════════════════
//  level_up_overlay.dart
// ═══════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LevelUpOverlay extends StatefulWidget {
  final int novoNivel;
  final VoidCallback onClose;
  const LevelUpOverlay({super.key, required this.novoNivel, required this.onClose});

  @override
  State<LevelUpOverlay> createState() => _LevelUpOverlayState();
}

class _LevelUpOverlayState extends State<LevelUpOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) widget.onClose();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.xpLevelColor(widget.novoNivel);
    final titulo = AppTheme.nivelTitulo(widget.novoNivel);
    return Material(
      color: Colors.black54,
      child: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Container(
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: color, width: 2),
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.4), blurRadius: 30, spreadRadius: 5),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('⚡', style: TextStyle(fontSize: 60)),
                  const SizedBox(height: 12),
                  Text('LEVEL UP!',
                      style: TextStyle(
                          color: color,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4)),
                  const SizedBox(height: 8),
                  Text('Nível ${widget.novoNivel}',
                      style: const TextStyle(color: AppTheme.text, fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(titulo,
                      style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: widget.onClose,
                    child: const Text('Continuar', style: TextStyle(color: AppTheme.accentLight)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
