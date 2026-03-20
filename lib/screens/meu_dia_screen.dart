// ═══════════════════════════════════════════════════════════
//  meu_dia_screen.dart — RegulOS  "Meu Dia"
//  Resumo diário: bateria de regulação + eventos por período
// ═══════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class MeuDiaScreen extends StatefulWidget {
  const MeuDiaScreen({super.key});
  @override
  State<MeuDiaScreen> createState() => _MeuDiaScreenState();
}

class _MeuDiaScreenState extends State<MeuDiaScreen> {
  late DateTime _semanaBase;

  @override
  void initState() {
    super.initState();
    final hoje = DateTime.now();
    _semanaBase = hoje.subtract(Duration(days: hoje.weekday % 7));
    WidgetsBinding.instance.addPostFrameCallback((_) => _verificarAvaliacaoMatinal());
  }

  // ── Avaliação matinal ─────────────────────────────────
  Future<void> _verificarAvaliacaoMatinal() async {
    final state = context.read<AppState>();
    final hoje = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final avaliacao = state.getAvaliacaoMatinal(hoje);
    final hora = TimeOfDay.now().hour;
    if (avaliacao == null && hora >= 5 && hora < 14) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) _mostrarAvaliacaoMatinal();
    }
  }

  Future<void> _mostrarAvaliacaoMatinal() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AvaliacaoMatinalSheet(),
    );
  }

  // ── Semana ────────────────────────────────────────────
  List<DateTime> get _diasSemana =>
      List.generate(7, (i) => _semanaBase.add(Duration(days: i)));

  // ── Build ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (ctx, state, _) {
      final avaliacao = state.getAvaliacaoMatinal(state.dataChave);
      final bateria = avaliacao?.bateriaRestante ?? -1;

      return Scaffold(
        backgroundColor: AppTheme.bg,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(state),
              _buildSemanaBarra(state),
              if (bateria >= 0) _buildBateriaCard(bateria, avaliacao!),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    _buildPeriodo('manha',   state),
                    _buildPeriodo('tarde',   state),
                    _buildPeriodo('noite',   state),
                    _buildPeriodo('anytime', state),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _mostrarAvaliacaoMatinal,
          tooltip: 'Avaliação matinal',
          child: const Icon(Icons.wb_sunny_rounded),
        ),
      );
    });
  }

  // ── Header ────────────────────────────────────────────
  Widget _buildHeader(AppState state) {
    final diasPT = ['dom','seg','ter','qua','qui','sex','sáb'];
    final semana = ['Domingo','Segunda','Terça','Quarta','Quinta','Sexta','Sábado'];
    final mes = DateFormat('MMMM yyyy', 'pt_BR').format(state.dataSelecionada);
    final diaIdx = state.dataSelecionada.weekday % 7;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(semana[diaIdx],
                  style: GoogleStyleText.displayDay),
                if (!state.isHoje)
                  TextButton.icon(
                    onPressed: state.irParaHoje,
                    icon: const Icon(Icons.today_rounded, size: 14),
                    label: const Text('Voltar para hoje'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.accent,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(mes.toUpperCase(),
                style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 11,
                  fontWeight: FontWeight.w600, letterSpacing: 1)),
              Text(DateFormat('d', 'pt_BR').format(state.dataSelecionada),
                style: const TextStyle(
                  color: AppTheme.text, fontSize: 36,
                  fontWeight: FontWeight.bold, height: 1.0)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Barra semanal ─────────────────────────────────────
  Widget _buildSemanaBarra(AppState state) {
    final diasAbrev = ['D','S','T','Q','Q','S','S'];
    final hoje = DateTime.now();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => setState(() =>
              _semanaBase = _semanaBase.subtract(const Duration(days: 7))),
            icon: const Icon(Icons.chevron_left_rounded),
            iconSize: 20, color: AppTheme.textMuted,
            padding: EdgeInsets.zero, constraints: const BoxConstraints(),
          ),
          ..._diasSemana.map((dia) {
            final isSelected = dia.year == state.dataSelecionada.year &&
                dia.month == state.dataSelecionada.month &&
                dia.day == state.dataSelecionada.day;
            final isToday = dia.year == hoje.year &&
                dia.month == hoje.month && dia.day == hoje.day;
            final idx = dia.weekday % 7;
            return GestureDetector(
              onTap: () => state.setDataSelecionada(dia),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40, height: 56,
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: isToday && !isSelected
                    ? Border.all(color: AppTheme.accent.withOpacity(0.4), width: 1.5)
                    : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(diasAbrev[idx],
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : AppTheme.textMuted)),
                    const SizedBox(height: 4),
                    Text('${dia.day}',
                      style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppTheme.text)),
                  ],
                ),
              ),
            );
          }),
          IconButton(
            onPressed: () => setState(() =>
              _semanaBase = _semanaBase.add(const Duration(days: 7))),
            icon: const Icon(Icons.chevron_right_rounded),
            iconSize: 20, color: AppTheme.textMuted,
            padding: EdgeInsets.zero, constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // ── Card da bateria ───────────────────────────────────
  Widget _buildBateriaCard(int bateria, AvaliacaoMatinal av) {
    final cor = AppTheme.corBateria(bateria);
    final pct = (bateria / 100).clamp(0.0, 1.0);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cor.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Text(AppTheme.emojiBateria(bateria), style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Energia de Regulação',
                      style: TextStyle(fontWeight: FontWeight.w600,
                        fontSize: 12, color: AppTheme.text)),
                    Text('$bateria / ${av.bateriaInicial}',
                      style: TextStyle(fontWeight: FontWeight.bold,
                        fontSize: 13, color: cor)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct, minHeight: 6,
                    backgroundColor: cor.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(cor),
                  ),
                ),
                if (bateria < 40) ...[
                  const SizedBox(height: 4),
                  const Text('⚠️ Bateria baixa — cuide de você agora',
                    style: TextStyle(fontSize: 11, color: AppTheme.red,
                      fontWeight: FontWeight.w500)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _mostrarRecarga(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.green.withOpacity(0.3)),
              ),
              child: const Text('+ recarregar',
                style: TextStyle(fontSize: 11, color: AppTheme.green,
                  fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Seção por período ─────────────────────────────────
  Widget _buildPeriodo(String periodo, AppState state) {
    final data = state.dataChave;
    final tarefas = state.tarefasNoPeriodo(periodo, data);
    final reunioes = state.reunioesNoPeriodo(periodo, data);
    final compromissos = state.compromissosNoPeriodo(periodo, data);
    final total = tarefas.length + reunioes.length + compromissos.length;

    return _PeriodoSection(
      periodo: periodo,
      tarefas: tarefas,
      reunioes: reunioes,
      compromissos: compromissos,
      total: total,
      onAddTarefa: () => _adicionarItem(periodo, state),
    );
  }

  void _adicionarItem(String periodo, AppState state) {
    // Navega para aba de tarefas passando o período
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Use a aba Tarefas para adicionar no período '
          '${AppTheme.labelPeriodo(periodo)}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.accent,
      ),
    );
  }

  // ── Modal de recarga ──────────────────────────────────
  void _mostrarRecarga(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => const _RecargaSheet(),
    );
  }
}

// ── Estilo de texto do dia ────────────────────────────
class GoogleStyleText {
  static const TextStyle displayDay = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 28, fontWeight: FontWeight.w400,
    color: AppTheme.text, letterSpacing: -0.5,
  );
}

// ═══════════════════════════════════════════════════════════
//  Widget: Seção de período
// ═══════════════════════════════════════════════════════════
class _PeriodoSection extends StatefulWidget {
  final String periodo;
  final List<Tarefa> tarefas;
  final List<Reuniao> reunioes;
  final List<Compromisso> compromissos;
  final int total;
  final VoidCallback onAddTarefa;

  const _PeriodoSection({
    required this.periodo, required this.tarefas,
    required this.reunioes, required this.compromissos,
    required this.total, required this.onAddTarefa,
  });

  @override
  State<_PeriodoSection> createState() => _PeriodoSectionState();
}

class _PeriodoSectionState extends State<_PeriodoSection> {
  bool _expandido = true;

  @override
  Widget build(BuildContext context) {
    final cor = AppTheme.corPeriodo(widget.periodo);
    final label = AppTheme.labelPeriodo(widget.periodo);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header da seção
        GestureDetector(
          onTap: () => setState(() => _expandido = !_expandido),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: cor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(label,
                        style: const TextStyle(fontSize: 11,
                          fontWeight: FontWeight.w700, color: AppTheme.text,
                          letterSpacing: 0.5)),
                      const SizedBox(width: 4),
                      Text('(${widget.total})',
                        style: const TextStyle(fontSize: 11,
                          color: AppTheme.textMuted)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _expandido ? Icons.keyboard_arrow_down_rounded
                              : Icons.keyboard_arrow_right_rounded,
                  size: 18, color: AppTheme.textMuted),
              ],
            ),
          ),
        ),

        if (_expandido) ...[
          // Tarefas
          ...widget.tarefas.map((t) => _TarefaCard(tarefa: t)),
          // Reuniões
          ...widget.reunioes.map((r) => _ReuniaoCard(reuniao: r)),
          // Compromissos
          ...widget.compromissos.map((c) => _CompromissoCard(compromisso: c)),

          // Card vazio (placeholder)
          if (widget.total == 0)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.divider,
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                dense: true,
                title: Text(_placeholder(widget.periodo),
                  style: const TextStyle(color: AppTheme.textMuted,
                    fontSize: 13, fontStyle: FontStyle.italic)),
                trailing: GestureDetector(
                  onTap: widget.onAddTarefa,
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.divider),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add_rounded,
                      size: 16, color: AppTheme.textMuted),
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }

  String _placeholder(String p) {
    switch (p) {
      case 'manha':   return 'O que está na sua lista da manhã?';
      case 'tarde':   return 'O que acontece hoje à tarde?';
      case 'noite':   return 'Como terminar o dia?';
      default:        return 'A qualquer hora — sem pressa';
    }
  }
}

// ── Card de tarefa ─────────────────────────────────────
class _TarefaCard extends StatelessWidget {
  final Tarefa tarefa;
  const _TarefaCard({required this.tarefa});

  @override
  Widget build(BuildContext context) {
    final atrasada = tarefa.dataPrazo != null &&
        tarefa.dataPrazo!.isBefore(DateTime.now()) && !tarefa.concluida;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 2, 16, 2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: atrasada ? AppTheme.red.withOpacity(0.3) : AppTheme.divider),
        boxShadow: [BoxShadow(
          color: AppTheme.shadow, blurRadius: 4, offset: const Offset(0,1))],
      ),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              color: _corTipo(tarefa.tipo),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tarefa.titulo,
                  style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500,
                    color: AppTheme.text,
                    decoration: tarefa.concluida ? TextDecoration.lineThrough : null)),
                if (tarefa.dataPrazo != null)
                  Text(
                    atrasada ? '⚠️ Atrasada' :
                    '⏰ ${DateFormat('HH:mm').format(tarefa.dataPrazo!)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: atrasada ? AppTheme.red : AppTheme.textMuted)),
              ],
            ),
          ),
          Text('−${tarefa.custoRegulacao}⚡',
            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          if (tarefa.concluida)
            const Padding(
              padding: EdgeInsets.only(left: 6),
              child: Icon(Icons.check_circle_rounded,
                size: 16, color: AppTheme.green)),
        ],
      ),
    );
  }

  Color _corTipo(String tipo) {
    switch (tipo) {
      case 'critica':    return AppTheme.red;
      case 'importante': return AppTheme.orange;
      case 'urgente':    return AppTheme.gold;
      default:           return AppTheme.accent;
    }
  }
}

// ── Card de reunião ────────────────────────────────────
class _ReuniaoCard extends StatelessWidget {
  final Reuniao reuniao;
  const _ReuniaoCard({required this.reuniao});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 2, 16, 2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.blue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.groups_rounded, size: 14, color: AppTheme.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reuniao.titulo,
                  style: const TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w500, color: AppTheme.text)),
                Text(
                  '${DateFormat('HH:mm').format(reuniao.dataHora)} · ${reuniao.duracaoMinutos}min',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ),
          Text('−${AppTheme.custoRegulacaoReuniao(reuniao.duracaoMinutos)}⚡',
            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
        ],
      ),
    );
  }
}

// ── Card de compromisso ────────────────────────────────
class _CompromissoCard extends StatelessWidget {
  final Compromisso compromisso;
  const _CompromissoCard({required this.compromisso});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 2, 16, 2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.purple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.purple.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_rounded, size: 14, color: AppTheme.purple),
          const SizedBox(width: 10),
          Expanded(
            child: Text(compromisso.titulo,
              style: const TextStyle(fontSize: 13,
                fontWeight: FontWeight.w500, color: AppTheme.text)),
          ),
          Text(DateFormat('HH:mm').format(compromisso.dataHora),
            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Sheet: Avaliação Matinal
// ═══════════════════════════════════════════════════════════
class _AvaliacaoMatinalSheet extends StatefulWidget {
  const _AvaliacaoMatinalSheet();
  @override
  State<_AvaliacaoMatinalSheet> createState() => _AvaliacaoMatinalSheetState();
}

class _AvaliacaoMatinalSheetState extends State<_AvaliacaoMatinalSheet> {
  int _sono = 3, _humor = 3, _energiaFisica = 3, _stress = 2;
  bool _dorFisica = false;
  final _obsCtrl = TextEditingController();

  int _calcularBateria() {
    int bateria = 100;
    if (_sono <= 2)         bateria -= 20;
    else if (_sono == 3)    bateria -= 10;
    if (_humor <= 2)        bateria -= 15;
    else if (_humor == 3)   bateria -= 5;
    if (_energiaFisica <= 2) bateria -= 10;
    if (_stress >= 4)       bateria -= 15;
    else if (_stress == 3)  bateria -= 5;
    if (_dorFisica)         bateria -= 10;
    return bateria.clamp(30, 100);
  }

  @override
  Widget build(BuildContext context) {
    final bateria = _calcularBateria();
    final cor = AppTheme.corBateria(bateria);

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 36, height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            const Text('🌅 Como você acordou hoje?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                color: AppTheme.text)),
            const SizedBox(height: 4),
            const Text('Isso define sua bateria de regulação inicial',
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
            const SizedBox(height: 20),

            _buildSlider('😴 Qualidade do sono',
              ['Péssimo','Ruim','Regular','Bom','Ótimo'], _sono,
              (v) => setState(() => _sono = v)),
            _buildSlider('😊 Humor ao acordar',
              ['Muito ruim','Ruim','Neutro','Bom','Ótimo'], _humor,
              (v) => setState(() => _humor = v)),
            _buildSlider('⚡ Energia física',
              ['Exausto','Cansado','Regular','Bem','Ótimo'], _energiaFisica,
              (v) => setState(() => _energiaFisica = v)),
            _buildSlider('😤 Nível de stress',
              ['Nenhum','Leve','Moderado','Alto','Intenso'], _stress,
              (v) => setState(() => _stress = v)),

            Row(
              children: [
                Checkbox(
                  value: _dorFisica,
                  onChanged: (v) => setState(() => _dorFisica = v ?? false),
                  activeColor: AppTheme.accent,
                ),
                const Text('Sinto dor ou desconforto físico hoje',
                  style: TextStyle(fontSize: 13, color: AppTheme.text)),
              ],
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _obsCtrl,
              decoration: const InputDecoration(
                hintText: 'Observação opcional (sonho, evento de ontem...)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Preview da bateria
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Sua bateria hoje começa em:',
                    style: TextStyle(fontSize: 13, color: AppTheme.text)),
                  Text('$bateria / 100',
                    style: TextStyle(fontSize: 20,
                      fontWeight: FontWeight.bold, color: cor)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _salvar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Começar o dia 🚀',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(String label, List<String> opcoes, int valor,
      ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.text)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(opcoes[valor - 1],
                style: const TextStyle(fontSize: 11,
                  color: AppTheme.accent, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        Row(
          children: List.generate(5, (i) => Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i + 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.all(3),
                height: 8,
                decoration: BoxDecoration(
                  color: i < valor
                    ? AppTheme.accent
                    : AppTheme.divider,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          )),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Future<void> _salvar() async {
    final bateria = _calcularBateria();
    await context.read<AppState>().salvarAvaliacaoMatinalNomeada(
      qualidadeSono: _sono,
      humor: _humor,
      energiaFisica: _energiaFisica,
      nivelStress: _stress,
      dorFisica: _dorFisica,
      bateriaInicial: bateria,
      observacoes: _obsCtrl.text,
    );
    if (mounted) Navigator.pop(context);
  }
}

// ═══════════════════════════════════════════════════════════
//  Sheet: Recarga de Regulação
// ═══════════════════════════════════════════════════════════
class _RecargaSheet extends StatelessWidget {
  const _RecargaSheet();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (ctx, state, _) {
      final atividades = state.atividadesRecarga;
      return Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 36, height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            const Text('🔋 Recarregar Regulação',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                color: AppTheme.text)),
            const SizedBox(height: 4),
            const Text('Toque na atividade que você fez',
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: atividades.map((a) => GestureDetector(
                onTap: () async {
                  await state.registrarRecarga(a);
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                      content: Text(
                        '${a.icone} +${a.pontosRecuperacao} pontos de regulação!'),
                      backgroundColor: AppTheme.green,
                      behavior: SnackBarBehavior.floating,
                    ));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.green.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.green.withOpacity(0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(a.icone,
                        style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(a.nome,
                        style: const TextStyle(
                          fontSize: 13, color: AppTheme.text,
                          fontWeight: FontWeight.w500)),
                      const SizedBox(width: 6),
                      Text('+${a.pontosRecuperacao}',
                        style: const TextStyle(
                          fontSize: 11, color: AppTheme.green,
                          fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    });
  }
}
