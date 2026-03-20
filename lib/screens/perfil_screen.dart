// ═══════════════════════════════════════════════════════════
//  perfil_screen.dart — RegulOS
//  Perfil do usuário: nível, XP, conquistas, streak
// ═══════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/xp_badge.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, state, _) {
      final p = state.perfil;
      final conquistas = state.boxConquistas.values.toList();
      conquistas.sort((a, b) => (b.desbloqueada ? 1 : 0) - (a.desbloqueada ? 1 : 0));

      return Scaffold(
        backgroundColor: AppTheme.bg,
        appBar: AppBar(
          title: const Text('👤 Perfil'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () => _editarPerfil(context, state, p),
              tooltip: 'Editar perfil',
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Header ──────────────────────────────────
            _HeaderCard(perfil: p, state: state),
            const SizedBox(height: 12),

            // ── XP Badge ────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: XpBadge(
                  nivel: p.nivel,
                  xpAtual: p.xpTotal,
                  xpProximo: AppTheme.xpParaProximoNivel(p.nivel),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Stats rápidas ────────────────────────────
            _StatsRow(perfil: p),
            const SizedBox(height: 16),

            // ── Conquistas ───────────────────────────────
            _SectionTitle(title: '🏆 Conquistas', count: conquistas.where((c) => c.desbloqueada).length, total: conquistas.length),
            const SizedBox(height: 8),
            if (conquistas.isEmpty)
              const _EmptyState(
                icon: Icons.emoji_events_outlined,
                message: 'Complete tarefas para desbloquear conquistas!',
              )
            else
              ...conquistas.map((c) => _ConquistaCard(conquista: c)),

            const SizedBox(height: 80),
          ],
        ),
      );
    });
  }

  void _editarPerfil(BuildContext context, AppState state, Perfil p) {
    final nomeCtrl = TextEditingController(text: p.nome);
    final descCtrl = TextEditingController(text: p.descricao);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Text('✏️ Editar Perfil',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.text)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ]),
              const SizedBox(height: 16),
              TextField(
                controller: nomeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  prefixIcon: Icon(Icons.person_rounded, color: AppTheme.accent),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Sobre você (opcional)',
                  prefixIcon: Icon(Icons.notes_rounded, color: AppTheme.accent),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final nome = nomeCtrl.text.trim();
                    if (nome.isNotEmpty) {
                      final perfil = state.perfil;
                      perfil.nome = nome;
                      perfil.descricao = descCtrl.text.trim();
                      perfil.save();
                      state.notifyListeners();
                    }
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(backgroundColor: AppTheme.accent),
                  child: const Text('Salvar', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Header Card ───────────────────────────────────────────
class _HeaderCard extends StatelessWidget {
  final Perfil perfil;
  final AppState state;
  const _HeaderCard({required this.perfil, required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppTheme.accent, AppTheme.accentLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accent.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  (state.currentUser?.displayName ?? perfil.nome).isNotEmpty
                      ? (state.currentUser?.displayName ?? perfil.nome)[0].toUpperCase()
                      : 'R',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.currentUser?.displayName ?? perfil.nome,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    state.currentUser?.email ?? '',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                  if (perfil.descricao.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      perfil.descricao,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.gold.withOpacity(0.4)),
                    ),
                    child: Text(
                      '⭐ Nível ${perfil.nivel} — ${AppTheme.nomaNivel(perfil.nivel)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stats Row ─────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final Perfil perfil;
  const _StatsRow({required this.perfil});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCard(
          icon: Icons.local_fire_department_rounded,
          color: AppTheme.orange,
          value: '${perfil.streakAtual}',
          label: 'Streak atual',
          sublabel: '🔥 dias',
        )),
        const SizedBox(width: 8),
        Expanded(child: _StatCard(
          icon: Icons.emoji_events_rounded,
          color: AppTheme.gold,
          value: '${perfil.streakMaximo}',
          label: 'Maior streak',
          sublabel: '🏆 dias',
        )),
        const SizedBox(width: 8),
        Expanded(child: _StatCard(
          icon: Icons.task_alt_rounded,
          color: AppTheme.green,
          value: '${perfil.totalTarefasConcluidas}',
          label: 'Tarefas',
          sublabel: '✅ feitas',
        )),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final String sublabel;
  const _StatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(label,
                style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                textAlign: TextAlign.center),
            Text(sublabel,
                style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }
}

// ── Section Title ─────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  final int count;
  final int total;
  const _SectionTitle({required this.title, required this.count, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.text)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('$count/$total',
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accent)),
        ),
      ],
    );
  }
}

// ── Conquista Card ────────────────────────────────────────
class _ConquistaCard extends StatelessWidget {
  final Conquista conquista;
  const _ConquistaCard({required this.conquista});

  @override
  Widget build(BuildContext context) {
    final desbloqueada = conquista.desbloqueada;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: desbloqueada
                ? AppTheme.gold.withOpacity(0.15)
                : AppTheme.divider,
          ),
          child: Center(
            child: Text(
              conquista.icone,
              style: TextStyle(
                fontSize: 22,
                color: desbloqueada ? null : const Color(0xFF999999),
              ),
            ),
          ),
        ),
        title: Text(
          conquista.titulo,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: desbloqueada ? AppTheme.text : AppTheme.textMuted,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(conquista.descricao,
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
            if (desbloqueada && conquista.desbloquadaEm != null)
              Text(
                '🗓 Desbloqueada em ${_formatData(conquista.desbloquadaEm!)}',
                style: const TextStyle(fontSize: 11, color: AppTheme.green),
              ),
          ],
        ),
        trailing: desbloqueada
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.gold.withOpacity(0.4)),
                ),
                child: Text('+${conquista.xpBonus} XP',
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.text)),
              )
            : const Icon(Icons.lock_outline_rounded, color: AppTheme.textMuted, size: 18),
      ),
    );
  }

  String _formatData(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}

// ── Empty State ───────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(icon, size: 48, color: AppTheme.textMuted),
            const SizedBox(height: 12),
            Text(message,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
