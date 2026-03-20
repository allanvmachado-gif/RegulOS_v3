// ═══════════════════════════════════════════════════════════
//  xp_badge.dart
// ═══════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class XpBadge extends StatelessWidget {
  final int nivel;
  final int xpAtual;
  final int xpProximo;
  final bool compact;

  const XpBadge({
    super.key,
    required this.nivel,
    required this.xpAtual,
    required this.xpProximo,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.xpLevelColor(nivel);
    final progress = xpProximo > 0 ? (xpAtual / xpProximo).clamp(0.0, 1.0) : 1.0;

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bolt_rounded, color: color, size: 14),
            const SizedBox(width: 4),
            Text('Nv $nivel', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt_rounded, color: color, size: 16),
                  const SizedBox(width: 4),
                  Text('Nível $nivel — ${AppTheme.nivelTitulo(nivel)}',
                      style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Spacer(),
            Text('$xpAtual / ${xpProximo == 999999 ? "MAX" : "$xpProximo"} XP',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppTheme.divider,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
