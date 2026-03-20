// ═══════════════════════════════════════════════════════════
//  rotina_screen.dart
// ═══════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class RotinaScreen extends StatelessWidget {
  const RotinaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final score = state.scoreDiaAtual;
        return Scaffold(
          backgroundColor: AppTheme.bg,
          appBar: AppBar(
            title: const Text('⏰ Rotina'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded),
                onPressed: () => _showBlocoDialog(context, state),
                tooltip: 'Novo bloco',
              ),
            ],
          ),
          body: Column(
            children: [
              _buildDateNav(context, state),
              _buildScoreBar(context, score),
              Expanded(child: _buildBlocos(context, state)),
            ],
          ),
        );
      },
    );
  }

  // ─── Navegação de data ────────────────────────────────────
  Widget _buildDateNav(BuildContext context, AppState state) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, color: AppTheme.textMuted),
            onPressed: state.voltarDia,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _showDatePicker(context, state),
              child: Column(
                children: [
                  Text(
                    state.dataFormatada,
                    style: const TextStyle(
                        color: AppTheme.text, fontWeight: FontWeight.w600, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  if (!state.isHoje)
                    const Text('(toque para escolher data)',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                ],
              ),
            ),
          ),
          if (!state.isHoje)
            TextButton(
              onPressed: state.irParaHoje,
              child: const Text('Hoje', style: TextStyle(color: AppTheme.accentLight, fontSize: 12)),
            ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
            onPressed: state.avancarDia,
          ),
        ],
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context, AppState state) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: state.dataSelecionada,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (c, w) => Theme(
        data: Theme.of(c).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppTheme.accent),
        ),
        child: w!,
      ),
    );
    if (picked != null) state.setDataSelecionada(picked);
  }

  // ─── Barra de score ────────────────────────────────────────
  Widget _buildScoreBar(BuildContext context, double score) {
    final pct = (score * 100).round();
    final color = pct >= 80
        ? AppTheme.green
        : pct >= 50
            ? AppTheme.orange
            : AppTheme.red;
    final msg = pct >= 80
        ? '🔥 Excelente dia!'
        : pct >= 50
            ? '💪 Bom progresso!'
            : pct > 0
                ? '✨ Continue assim!'
                : '📅 Sem registros ainda';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Score do dia', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              Text('$pct%', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score,
              minHeight: 8,
              backgroundColor: AppTheme.divider,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 6),
          Text(msg, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        ],
      ),
    );
  }

  // ─── Lista de blocos ───────────────────────────────────────
  Widget _buildBlocos(BuildContext context, AppState state) {
    final blocos = state.blocosAtivos;
    if (blocos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.schedule_rounded, color: AppTheme.textMuted, size: 48),
            const SizedBox(height: 16),
            const Text('Nenhum bloco para hoje',
                style: TextStyle(color: AppTheme.textMuted)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_rounded),
              label: const Text('Criar bloco'),
              onPressed: () => _showBlocoDialog(context, state),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: blocos.length,
      itemBuilder: (context, i) => _BlocoCard(
        bloco: blocos[i],
        state: state,
        onEdit: () => _showBlocoDialog(context, state, existing: blocos[i]),
      ),
    );
  }

  // ─── Dialog criar/editar bloco ─────────────────────────────
  void _showBlocoDialog(BuildContext context, AppState state, {BlocoRotina? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => BlocoFormSheet(existing: existing, state: state),
    );
  }
}

// ─── BlocoCard ─────────────────────────────────────────────
class _BlocoCard extends StatelessWidget {
  final BlocoRotina bloco;
  final AppState state;
  final VoidCallback onEdit;

  const _BlocoCard({required this.bloco, required this.state, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final ci = state.getCheckIn(bloco.id, state.dataChave);
    final cor = Color(int.tryParse('0xFF${bloco.cor.replaceAll('#', '')}') ?? 0xFF7C3AED);

    return Card(
      child: InkWell(
        onLongPress: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: cor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(bloco.icone, style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(bloco.titulo,
                            style: const TextStyle(
                                color: AppTheme.text, fontWeight: FontWeight.w600)),
                        Text('${bloco.horarioInicio} - ${bloco.horarioFim}',
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                  if (ci != null)
                    _statusChip(ci.status),
                ],
              ),
              if (bloco.descricao.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(bloco.descricao,
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _CheckBtn(
                    label: '✅ Feito',
                    active: ci?.status == 'feito',
                    color: AppTheme.green,
                    onTap: () => state.registrarCheckIn(bloco.id, 'feito'),
                  ),
                  const SizedBox(width: 8),
                  _CheckBtn(
                    label: '⚡ Parcial',
                    active: ci?.status == 'parcial',
                    color: AppTheme.orange,
                    onTap: () => state.registrarCheckIn(bloco.id, 'parcial'),
                  ),
                  const SizedBox(width: 8),
                  _CheckBtn(
                    label: '❌ Pulei',
                    active: ci?.status == 'pulei',
                    color: AppTheme.red,
                    onTap: () => state.registrarCheckIn(bloco.id, 'pulei'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final map = {
      'feito': ('✅', AppTheme.green),
      'parcial': ('⚡', AppTheme.orange),
      'pulei': ('❌', AppTheme.red),
    };
    final (emoji, color) = map[status] ?? ('?', AppTheme.textMuted);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 16)),
    );
  }
}

class _CheckBtn extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _CheckBtn({
    required this.label, required this.active,
    required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? color.withOpacity(0.2) : AppTheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active ? color : AppTheme.divider,
              width: active ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    color: active ? color : AppTheme.textMuted,
                    fontSize: 12,
                    fontWeight: active ? FontWeight.bold : FontWeight.normal),
                overflow: TextOverflow.ellipsis),
          ),
        ),
      ),
    );
  }
}

// ─── BlocoFormSheet ───────────────────────────────────────
class BlocoFormSheet extends StatefulWidget {
  final BlocoRotina? existing;
  final AppState state;
  const BlocoFormSheet({super.key, this.existing, required this.state});

  @override
  State<BlocoFormSheet> createState() => _BlocoFormSheetState();
}

class _BlocoFormSheetState extends State<BlocoFormSheet> {
  final _uuid = const Uuid();
  late final TextEditingController _tituloCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _iconeCtrl;
  String _inicio = '08:00';
  String _fim = '09:00';
  String _cor = '7C3AED';
  List<int> _dias = [1, 2, 3, 4, 5];
  bool _notificar = true;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _tituloCtrl = TextEditingController(text: e?.titulo ?? '');
    _descCtrl = TextEditingController(text: e?.descricao ?? '');
    _iconeCtrl = TextEditingController(text: e?.icone ?? '📌');
    if (e != null) {
      _inicio = e.horarioInicio;
      _fim = e.horarioFim;
      _cor = e.cor.replaceAll('#', '');
      _dias = List.from(e.diasSemana);
      _notificar = e.notificar;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(isEdit ? 'Editar Bloco' : 'Novo Bloco',
                  style: const TextStyle(
                      color: AppTheme.text, fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (isEdit)
                IconButton(
                  icon: const Icon(Icons.delete_rounded, color: AppTheme.red),
                  onPressed: () async {
                    await widget.state.deletarBloco(widget.existing!);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _iconeCtrl,
                  decoration: const InputDecoration(labelText: 'Ícone'),
                  style: const TextStyle(fontSize: 24, color: AppTheme.text),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _tituloCtrl,
                  decoration: const InputDecoration(labelText: 'Título'),
                  style: const TextStyle(color: AppTheme.text),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descCtrl,
            decoration: const InputDecoration(labelText: 'Descrição (opcional)'),
            style: const TextStyle(color: AppTheme.text),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _horarioPicker('Início', _inicio,
                  (t) => setState(() => _inicio = t))),
              const SizedBox(width: 12),
              Expanded(child: _horarioPicker('Fim', _fim,
                  (t) => setState(() => _fim = t))),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Dias da semana', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          const SizedBox(height: 6),
          _diasPicker(),
          const SizedBox(height: 12),
          SwitchListTile(
            value: _notificar,
            onChanged: (v) => setState(() => _notificar = v),
            title: const Text('Notificação', style: TextStyle(color: AppTheme.text, fontSize: 13)),
            activeColor: AppTheme.accent,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _salvar,
              child: Text(isEdit ? 'Salvar alterações' : 'Criar bloco'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _horarioPicker(String label, String value, ValueChanged<String> onChanged) {
    return InkWell(
      onTap: () async {
        final parts = value.split(':');
        final tod = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(
              hour: int.parse(parts[0]), minute: int.parse(parts[1])),
          builder: (c, w) => Theme(
            data: Theme.of(c).copyWith(
                colorScheme: const ColorScheme.dark(primary: AppTheme.accent)),
            child: w!,
          ),
        );
        if (tod != null) {
          onChanged(
              '${tod.hour.toString().padLeft(2, '0')}:${tod.minute.toString().padLeft(2, '0')}');
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(value, style: const TextStyle(color: AppTheme.text)),
      ),
    );
  }

  Widget _diasPicker() {
    const labels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = i + 1;
        final sel = _dias.contains(day);
        return GestureDetector(
          onTap: () => setState(() {
            if (sel) _dias.remove(day); else _dias.add(day);
          }),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: sel ? AppTheme.accent : AppTheme.card,
              border: Border.all(color: sel ? AppTheme.accent : AppTheme.divider),
            ),
            child: Center(
              child: Text(labels[i],
                  style: TextStyle(
                      color: sel ? Colors.white : AppTheme.textMuted,
                      fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      }),
    );
  }

  void _salvar() async {
    if (_tituloCtrl.text.trim().isEmpty) return;
    final bloco = widget.existing ??
        (BlocoRotina()
          ..id = _uuid.v4()
          ..ativo = true);
    bloco
      ..titulo = _tituloCtrl.text.trim()
      ..descricao = _descCtrl.text.trim()
      ..icone = _iconeCtrl.text.trim().isEmpty ? '📌' : _iconeCtrl.text.trim()
      ..horarioInicio = _inicio
      ..horarioFim = _fim
      ..cor = _cor
      ..diasSemana = _dias
      ..notificar = _notificar;

    if (widget.existing != null) {
      await widget.state.editarBloco(bloco);
    } else {
      await widget.state.adicionarBloco(bloco);
    }
    if (context.mounted) Navigator.pop(context);
  }
}
