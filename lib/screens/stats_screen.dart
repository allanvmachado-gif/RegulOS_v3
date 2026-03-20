// ═══════════════════════════════════════════════════════════
//  stats_screen.dart
// ═══════════════════════════════════════════════════════════
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/xp_badge.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, state, _) {
      final p = state.perfil;
      final nivelAtual = p.nivel;
      final xpAtual = p.xpTotal;
      final xpProximo = AppTheme.xpParaProximoNivel(nivelAtual);

      return Scaffold(
        backgroundColor: AppTheme.bg,
        appBar: AppBar(title: const Text('📊 Estatísticas')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // XP e Nível
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: XpBadge(
                  nivel: nivelAtual,
                  xpAtual: xpAtual,
                  xpProximo: xpProximo,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // KPIs
            _buildKpis(state),
            const SizedBox(height: 8),

            // Gráfico de barras — 14 dias
            _buildBarChart(state),
            const SizedBox(height: 8),

            // Heatmap 30 dias
            _buildHeatmap(state),
            const SizedBox(height: 8),

            // Conquistas
            _buildConquistas(state),
            const SizedBox(height: 80),
          ],
        ),
      );
    });
  }

  // ─── KPIs ─────────────────────────────────────────────────
  Widget _buildKpis(AppState state) {
    final p = state.perfil;
    return Row(
      children: [
        _KpiCard(label: 'Streak', value: '${p.streakAtual}🔥', color: AppTheme.orange),
        const SizedBox(width: 8),
        _KpiCard(label: 'Melhor\nStreak', value: '${p.streakMaximo}⭐', color: AppTheme.gold),
        const SizedBox(width: 8),
        _KpiCard(
            label: 'Dias\ncheck-in', value: '${state.diasComCheckin}',
            color: AppTheme.blue),
        const SizedBox(width: 8),
        _KpiCard(
            label: 'Média\n30d',
            value: '${(state.mediaScore30Dias * 100).round()}%',
            color: AppTheme.green),
      ],
    );
  }

  // ─── Gráfico barras ───────────────────────────────────────
  Widget _buildBarChart(AppState state) {
    final scores = state.getScores30Dias();
    final keys = scores.keys.toList();
    final last14 = keys.sublist(keys.length - 14);

    final bars = last14.asMap().entries.map((e) {
      final score = scores[e.value] ?? 0;
      final color = score >= 0.8
          ? AppTheme.green
          : score >= 0.5
              ? AppTheme.orange
              : score > 0
                  ? AppTheme.red
                  : AppTheme.divider;
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: score,
            color: color,
            width: 14,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📈 Score — últimos 14 dias',
                style: TextStyle(
                    color: AppTheme.text, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: BarChart(
                BarChartData(
                  maxY: 1,
                  minY: 0,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, meta) {
                          if (v.toInt() % 3 != 0) return const SizedBox();
                          final idx = v.toInt();
                          if (idx >= last14.length) return const SizedBox();
                          final day = DateTime.parse(last14[idx]).day;
                          return Text('$day',
                              style: const TextStyle(
                                  color: AppTheme.textMuted, fontSize: 10));
                        },
                      ),
                    ),
                  ),
                  barGroups: bars,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Heatmap ──────────────────────────────────────────────
  Widget _buildHeatmap(AppState state) {
    final scores = state.getScores30Dias();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🗓️ Consistência — 30 dias',
                style: TextStyle(
                    color: AppTheme.text, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: scores.entries.map((e) {
                final score = e.value;
                final color = score >= 0.8
                    ? AppTheme.green
                    : score >= 0.5
                        ? AppTheme.orange
                        : score > 0
                            ? AppTheme.red
                            : AppTheme.divider;
                final day = DateTime.parse(e.key).day;
                return Tooltip(
                  message: '${e.key}: ${(score * 100).round()}%',
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: color.withOpacity(score > 0 ? 0.7 : 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text('$day',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 9)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _legendItem(AppTheme.divider, 'Sem registro'),
                const SizedBox(width: 8),
                _legendItem(AppTheme.red, '< 50%'),
                const SizedBox(width: 8),
                _legendItem(AppTheme.orange, '50–79%'),
                const SizedBox(width: 8),
                _legendItem(AppTheme.green, '≥ 80%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(children: [
      Container(
          width: 12, height: 12,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
    ]);
  }

  // ─── Conquistas ───────────────────────────────────────────
  Widget _buildConquistas(AppState state) {
    final conquistas = state.boxConquistas.values.toList();
    if (conquistas.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🏅 Conquistas',
                style: TextStyle(
                    color: AppTheme.text, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.5,
              children: conquistas.map((c) => _ConquistaChip(conquista: c)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── KpiCard ─────────────────────────────────────────────
class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _KpiCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ─── ConquistaChip ────────────────────────────────────────
class _ConquistaChip extends StatelessWidget {
  final Conquista conquista;
  const _ConquistaChip({required this.conquista});

  @override
  Widget build(BuildContext context) {
    final unlocked = conquista.desbloqueada;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: unlocked
            ? AppTheme.gold.withOpacity(0.1)
            : AppTheme.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: unlocked ? AppTheme.gold.withOpacity(0.4) : AppTheme.divider,
        ),
      ),
      child: Row(
        children: [
          Text(conquista.icone,
              style: TextStyle(
                  fontSize: 18,
                  color: unlocked ? null : null),
              ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  conquista.titulo
                      .replaceAll(RegExp(r'[^\x00-\x7F]+'), '')
                      .trim(),
                  style: TextStyle(
                    color: unlocked ? AppTheme.text : AppTheme.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    decoration: unlocked ? null : TextDecoration.none,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text('+${conquista.xpBonus} XP',
                    style: TextStyle(
                        color: unlocked
                            ? AppTheme.gold
                            : AppTheme.textMuted.withOpacity(0.5),
                        fontSize: 10)),
              ],
            ),
          ),
          if (!unlocked)
            const Icon(Icons.lock_rounded, color: AppTheme.textMuted, size: 14),
        ],
      ),
    );
  }
}
