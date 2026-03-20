// ═══════════════════════════════════════════════════════════
//  diario_screen.dart — RegulOS v3
//  Post-its coloridos + objetivos/resultados + calendário
// ═══════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class DiarioScreen extends StatefulWidget {
  const DiarioScreen({super.key});
  @override
  State<DiarioScreen> createState() => _DiarioScreenState();
}

class _DiarioScreenState extends State<DiarioScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  DateTime _mesSelecionado = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (ctx, state, _) {
      return Scaffold(
        backgroundColor: AppTheme.bg,
        appBar: AppBar(
          backgroundColor: AppTheme.surface,
          elevation: 0,
          title: const Text('📓 Diário', style: TextStyle(
            color: AppTheme.text, fontWeight: FontWeight.bold)),
          bottom: TabBar(
            controller: _tabCtrl,
            indicatorColor: AppTheme.accent,
            labelColor: AppTheme.accent,
            unselectedLabelColor: AppTheme.textMuted,
            tabs: const [
              Tab(text: 'Post-its'),
              Tab(text: 'Calendário'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_rounded, color: AppTheme.accent),
              onPressed: () => _abrirEditor(ctx, state, null),
              tooltip: 'Nova entrada',
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _buildPostIts(ctx, state),
            _buildCalendario(ctx, state),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _abrirEditor(ctx, state, null),
          child: const Icon(Icons.edit_rounded),
        ),
      );
    });
  }

  // ── Aba 1: Post-its ────────────────────────────────────
  Widget _buildPostIts(BuildContext ctx, AppState state) {
    final entradas = List<EntradaDiario>.from(state.boxDiario.values.toList())
      ..sort((a, b) => b.data.compareTo(a.data));

    if (entradas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppTheme.postItColors[0],
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8, offset: const Offset(2, 4))],
              ),
              child: const Icon(Icons.sticky_note_2_rounded,
                size: 36, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 20),
            const Text('Nenhuma anotação ainda',
              style: TextStyle(color: AppTheme.text,
                fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            const Text('Registre objetivos, memórias e sentimentos',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _abrirEditor(ctx, state, null),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Criar primeira entrada'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: entradas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _PostItCard(
        entrada: entradas[i],
        onTap: () => _abrirEditor(ctx, state, entradas[i]),
        onDelete: () => _confirmarDelete(ctx, state, entradas[i]),
      ),
    );
  }

  // ── Aba 2: Calendário ──────────────────────────────────
  Widget _buildCalendario(BuildContext ctx, AppState state) {
    return Column(
      children: [
        _buildMesHeader(),
        _buildGradeCalendario(ctx, state),
        const Divider(height: 1),
        Expanded(child: _buildEntradasDia(ctx, state)),
      ],
    );
  }

  Widget _buildMesHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => setState(() =>
              _mesSelecionado = DateTime(
                _mesSelecionado.year, _mesSelecionado.month - 1)),
            icon: const Icon(Icons.chevron_left_rounded),
            color: AppTheme.textMuted,
          ),
          Text(
            DateFormat('MMMM yyyy', 'pt_BR').format(_mesSelecionado)
              .toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold,
              fontSize: 14, color: AppTheme.text, letterSpacing: 1)),
          IconButton(
            onPressed: () => setState(() =>
              _mesSelecionado = DateTime(
                _mesSelecionado.year, _mesSelecionado.month + 1)),
            icon: const Icon(Icons.chevron_right_rounded),
            color: AppTheme.textMuted,
          ),
        ],
      ),
    );
  }

  Widget _buildGradeCalendario(BuildContext ctx, AppState state) {
    final primeiroDia = DateTime(_mesSelecionado.year, _mesSelecionado.month, 1);
    final ultimoDia = DateTime(_mesSelecionado.year, _mesSelecionado.month + 1, 0);
    final offsetInicio = primeiroDia.weekday % 7;
    final hoje = DateTime.now();
    final diasAbrev = ['D','S','T','Q','Q','S','S'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          // Cabeçalho dias
          Row(
            children: diasAbrev.map((d) => Expanded(
              child: Center(
                child: Text(d, style: const TextStyle(
                  fontSize: 11, color: AppTheme.textMuted,
                  fontWeight: FontWeight.w600)),
              ),
            )).toList(),
          ),
          const SizedBox(height: 4),
          // Grade
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, childAspectRatio: 1),
            itemCount: offsetInicio + ultimoDia.day,
            itemBuilder: (_, idx) {
              if (idx < offsetInicio) return const SizedBox();
              final dia = idx - offsetInicio + 1;
              final data = DateTime(_mesSelecionado.year,
                _mesSelecionado.month, dia);
              final key = DateFormat('yyyy-MM-dd').format(data);
              final entrada = state.getEntradaDiario(key);
              final isHoje = data.year == hoje.year &&
                data.month == hoje.month && data.day == hoje.day;
              final isSelecionado = key == state.dataChave;

              return GestureDetector(
                onTap: () => state.setDataSelecionada(data),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelecionado ? AppTheme.accent
                      : entrada != null
                        ? AppTheme.postItColors[entrada.corPostIt]
                            .withOpacity(0.6)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isHoje && !isSelecionado
                      ? Border.all(color: AppTheme.accent, width: 1.5)
                      : null,
                  ),
                  child: Center(
                    child: Text('$dia',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelecionado || isHoje
                          ? FontWeight.bold : FontWeight.normal,
                        color: isSelecionado ? Colors.white : AppTheme.text)),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEntradasDia(BuildContext ctx, AppState state) {
    final entrada = state.getEntradaDiario(state.dataChave);
    final dataFormatada = DateFormat("d 'de' MMMM", 'pt_BR')
      .format(state.dataSelecionada);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dataFormatada,
                style: const TextStyle(fontWeight: FontWeight.bold,
                  fontSize: 15, color: AppTheme.text)),
              TextButton.icon(
                onPressed: () => _abrirEditor(ctx, state, entrada),
                icon: Icon(entrada == null
                  ? Icons.add_rounded : Icons.edit_rounded, size: 16),
                label: Text(entrada == null ? 'Adicionar' : 'Editar'),
                style: TextButton.styleFrom(foregroundColor: AppTheme.accent),
              ),
            ],
          ),
          if (entrada == null) ...[
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.divider,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.sticky_note_2_outlined,
                      color: AppTheme.textMuted, size: 28),
                  ),
                  const SizedBox(height: 12),
                  const Text('Sem anotação neste dia',
                    style: TextStyle(color: AppTheme.textMuted)),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            _PostItCard(
              entrada: entrada, expandido: true,
              onTap: () => _abrirEditor(ctx, state, entrada),
              onDelete: () => _confirmarDelete(ctx, state, entrada),
            ),
          ],
        ],
      ),
    );
  }

  // ── Abrir editor ───────────────────────────────────────
  void _abrirEditor(BuildContext ctx, AppState state,
      EntradaDiario? existing) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DiarioEditorSheet(
        entrada: existing,
        data: state.dataChave,
        dataSelecionada: state.dataSelecionada,
        onSave: (e) async {
          await state.salvarEntradaDiario(e);
          if (ctx.mounted) {
            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
              content: Text('Entrada salva ✓'),
              backgroundColor: AppTheme.green,
              behavior: SnackBarBehavior.floating,
            ));
          }
        },
      ),
    );
  }

  // ── Confirmar delete ───────────────────────────────────
  Future<void> _confirmarDelete(BuildContext ctx, AppState state,
      EntradaDiario e) async {
    final confirm = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Excluir entrada?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir',
              style: TextStyle(color: AppTheme.red))),
        ],
      ),
    );
    if (confirm == true) {
      await e.delete();
      if (ctx.mounted) setState(() {});
    }
  }
}

// ═══════════════════════════════════════════════════════════
//  Widget: Post-it card
// ═══════════════════════════════════════════════════════════
class _PostItCard extends StatelessWidget {
  final EntradaDiario entrada;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool expandido;

  const _PostItCard({
    required this.entrada, required this.onTap,
    required this.onDelete, this.expandido = false,
  });

  @override
  Widget build(BuildContext context) {
    final cor = AppTheme.postItColors[
      entrada.corPostIt.clamp(0, AppTheme.postItColors.length - 1)];
    final data = DateTime.tryParse(entrada.data);
    final dataStr = data != null
      ? DateFormat("d MMM", 'pt_BR').format(data) : entrada.data;

    final humorEmoji = {
      'otimo': '😄', 'bom': '🙂', 'neutro': '😐',
      'ruim': '😕', 'pessimo': '😢',
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8, offset: const Offset(2, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(entrada.memoriaPositiva ? '⭐' : '📌',
                  style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(dataStr,
                  style: const TextStyle(fontSize: 12,
                    fontWeight: FontWeight.w600, color: AppTheme.text)),
                const Spacer(),
                if (humorEmoji[entrada.humor] != null)
                  Text(humorEmoji[entrada.humor]!,
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(Icons.close_rounded,
                    size: 14, color: AppTheme.textMuted)),
              ],
            ),

            // Objetivos da manhã
            if (entrada.objetivosManha.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text('🎯 Objetivos do dia',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                  color: AppTheme.text)),
              const SizedBox(height: 4),
              Text(entrada.objetivosManha,
                style: const TextStyle(fontSize: 13, color: AppTheme.text),
                maxLines: expandido ? null : 2,
                overflow: expandido ? null : TextOverflow.ellipsis),
            ],

            // Anotação livre
            if (entrada.conteudo.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(entrada.conteudo,
                style: const TextStyle(fontSize: 13, color: AppTheme.text),
                maxLines: expandido ? null : 3,
                overflow: expandido ? null : TextOverflow.ellipsis),
            ],

            // Resultados da noite
            if (entrada.resultadoNoite.isNotEmpty && expandido) ...[
              const SizedBox(height: 10),
              const Divider(color: Colors.black12),
              const Text('✅ Como foi o dia',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                  color: AppTheme.text)),
              const SizedBox(height: 4),
              Text(entrada.resultadoNoite,
                style: const TextStyle(fontSize: 13, color: AppTheme.text)),
            ],

            // Tags
            if (entrada.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: entrada.tags.take(5).map((tag) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8)),
                  child: Text('#$tag',
                    style: const TextStyle(fontSize: 10,
                      color: AppTheme.text)),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Sheet: Editor do Diário
// ═══════════════════════════════════════════════════════════
class _DiarioEditorSheet extends StatefulWidget {
  final EntradaDiario? entrada;
  final String data;
  final DateTime dataSelecionada;
  final Function(EntradaDiario) onSave;

  const _DiarioEditorSheet({
    required this.entrada, required this.data,
    required this.dataSelecionada, required this.onSave,
  });

  @override
  State<_DiarioEditorSheet> createState() => _DiarioEditorSheetState();
}

class _DiarioEditorSheetState extends State<_DiarioEditorSheet> {
  final _uuid = const Uuid();
  late TextEditingController _objetivosCtrl;
  late TextEditingController _conteudoCtrl;
  late TextEditingController _resultadoCtrl;
  late TextEditingController _tagsCtrl;
  late String _humor;
  late int _corPostIt;
  late bool _memoriaPositiva;

  @override
  void initState() {
    super.initState();
    final e = widget.entrada;
    _objetivosCtrl  = TextEditingController(text: e?.objetivosManha ?? '');
    _conteudoCtrl   = TextEditingController(text: e?.conteudo ?? '');
    _resultadoCtrl  = TextEditingController(text: e?.resultadoNoite ?? '');
    _tagsCtrl       = TextEditingController(
      text: (e?.tags ?? []).join(', '));
    _humor          = e?.humor ?? 'neutro';
    _corPostIt      = e?.corPostIt ?? 0;
    _memoriaPositiva = e?.memoriaPositiva ?? true;
  }

  @override
  void dispose() {
    _objetivosCtrl.dispose();
    _conteudoCtrl.dispose();
    _resultadoCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataStr = DateFormat("EEEE, d 'de' MMMM", 'pt_BR')
      .format(widget.dataSelecionada);
    final corAtual = AppTheme.postItColors[_corPostIt];

    return Container(
      decoration: BoxDecoration(
        color: corAtual,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(width: 36, height: 4,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 12),

            // Header
            Row(
              children: [
                Expanded(
                  child: Text(dataStr,
                    style: const TextStyle(fontWeight: FontWeight.bold,
                      fontSize: 15, color: AppTheme.text)),
                ),
                // Cor do post-it
                ...List.generate(AppTheme.postItColors.length, (i) =>
                  GestureDetector(
                    onTap: () => setState(() => _corPostIt = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 20, height: 20,
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.postItColors[i],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _corPostIt == i
                            ? Colors.black45 : Colors.transparent,
                          width: 2),
                        boxShadow: [BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2)],
                      ),
                    ),
                  )),
              ],
            ),
            const SizedBox(height: 16),

            // Humor
            const Text('Como você está?',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                color: AppTheme.text)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _HumorBtn('😄','otimo',_humor,(v)=>setState(()=>_humor=v)),
                _HumorBtn('🙂','bom',  _humor,(v)=>setState(()=>_humor=v)),
                _HumorBtn('😐','neutro',_humor,(v)=>setState(()=>_humor=v)),
                _HumorBtn('😕','ruim', _humor,(v)=>setState(()=>_humor=v)),
                _HumorBtn('😢','pessimo',_humor,(v)=>setState(()=>_humor=v)),
              ],
            ),
            const SizedBox(height: 16),

            // Tipo de memória
            Row(
              children: [
                const Text('Esta é uma memória:',
                  style: TextStyle(fontSize: 12, color: AppTheme.text)),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => setState(() => _memoriaPositiva = true),
                  child: _MemoriaChip('⭐ Boa', _memoriaPositiva)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _memoriaPositiva = false),
                  child: _MemoriaChip('📌 Difícil', !_memoriaPositiva)),
              ],
            ),
            const SizedBox(height: 16),

            // Objetivos da manhã
            _buildTextField(_objetivosCtrl,
              '🎯 Objetivos do dia',
              'O que você quer conquistar hoje?', 3),
            const SizedBox(height: 12),

            // Anotação livre
            _buildTextField(_conteudoCtrl,
              '✏️ Anotações livres',
              'Pensamentos, sentimentos, observações...', 4),
            const SizedBox(height: 12),

            // Resultados da noite
            _buildTextField(_resultadoCtrl,
              '✅ Como foi o dia',
              'Resultados, aprendizados, como se sentiu...', 3),
            const SizedBox(height: 12),

            // Tags
            _buildTextField(_tagsCtrl,
              '🏷️ Tags (separadas por vírgula)',
              'trabalho, família, difícil, conquista...', 1),
            const SizedBox(height: 20),

            // Salvar
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
                  elevation: 0,
                ),
                child: const Text('Salvar entrada',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label,
      String hint, int lines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.text)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: lines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppTheme.textMuted.withOpacity(0.6),
              fontSize: 13),
            filled: true,
            fillColor: Colors.white.withOpacity(0.6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(12),
          ),
          style: const TextStyle(fontSize: 13, color: AppTheme.text),
        ),
      ],
    );
  }

  void _salvar() {
    final tags = _tagsCtrl.text
      .split(',').map((t) => t.trim())
      .where((t) => t.isNotEmpty).toList();
    final e = widget.entrada ?? EntradaDiario();
    e
      ..id              = widget.entrada?.id ?? _uuid.v4()
      ..data            = widget.data
      ..conteudo        = _conteudoCtrl.text
      ..humor           = _humor
      ..criadoEm        = widget.entrada?.criadoEm ?? DateTime.now()
      ..energiaNivel    = 3
      ..objetivosManha  = _objetivosCtrl.text
      ..resultadoNoite  = _resultadoCtrl.text
      ..corPostIt       = _corPostIt
      ..memoriaPositiva = _memoriaPositiva
      ..tags            = tags;
    widget.onSave(e);
    Navigator.pop(context);
  }
}

// ── Widgets auxiliares ────────────────────────────────
class _HumorBtn extends StatelessWidget {
  final String emoji, valor, humorAtual;
  final ValueChanged<String> onTap;
  const _HumorBtn(this.emoji, this.valor, this.humorAtual, this.onTap);

  @override
  Widget build(BuildContext context) {
    final sel = valor == humorAtual;
    return GestureDetector(
      onTap: () => onTap(valor),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: sel ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: sel ? AppTheme.accent : Colors.transparent, width: 2),
          boxShadow: sel ? [BoxShadow(
            color: AppTheme.accent.withOpacity(0.2),
            blurRadius: 4)] : null,
        ),
        child: Center(
          child: Text(emoji, style: const TextStyle(fontSize: 22))),
      ),
    );
  }
}

class _MemoriaChip extends StatelessWidget {
  final String label;
  final bool selecionado;
  const _MemoriaChip(this.label, this.selecionado);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selecionado ? AppTheme.accent : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selecionado ? AppTheme.accent : Colors.black12),
      ),
      child: Text(label,
        style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w500,
          color: selecionado ? Colors.white : AppTheme.text)),
    );
  }
}
