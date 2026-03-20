// ═══════════════════════════════════════════════════════════
//  tarefas_screen.dart
// ═══════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class TarefasScreen extends StatefulWidget {
  const TarefasScreen({super.key});

  @override
  State<TarefasScreen> createState() => _TarefasScreenState();
}

class _TarefasScreenState extends State<TarefasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  String _filtroArea = 'todos';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, state, _) {
      return Scaffold(
        backgroundColor: AppTheme.bg,
        appBar: AppBar(
          title: const Text('✅ Tarefas'),
          bottom: TabBar(
            controller: _tab,
            indicatorColor: AppTheme.accent,
            labelColor: AppTheme.accentLight,
            unselectedLabelColor: AppTheme.textMuted,
            tabs: [
              Tab(text: 'Pendentes (${state.tarefasPendentes.length})'),
              Tab(text: 'Concluídas (${state.tarefasConcluidas.length})'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tab,
          children: [
            _buildPendentes(state),
            _buildConcluidas(state),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showTarefaDialog(context, state),
          child: const Icon(Icons.add_rounded),
        ),
      );
    });
  }

  Widget _buildPendentes(AppState state) {
    final tarefas = state.tarefasPendentes;
    if (tarefas.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded,
                color: AppTheme.textMuted, size: 48),
            SizedBox(height: 16),
            Text('Nenhuma tarefa pendente! 🎉',
                style: TextStyle(color: AppTheme.textMuted)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: tarefas.length,
      itemBuilder: (_, i) => _TarefaCard(
        tarefa: tarefas[i],
        state: state,
        onEdit: () => _showTarefaDialog(context, state, existing: tarefas[i]),
      ),
    );
  }

  Widget _buildConcluidas(AppState state) {
    final tarefas = state.tarefasConcluidas;
    if (tarefas.isEmpty) {
      return const Center(
        child: Text('Nenhuma tarefa concluída ainda',
            style: TextStyle(color: AppTheme.textMuted)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: tarefas.length,
      itemBuilder: (_, i) => _TarefaCard(
        tarefa: tarefas[i],
        state: state,
        onEdit: () {},
      ),
    );
  }

  void _showTarefaDialog(BuildContext context, AppState state,
      {Tarefa? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => TarefaFormSheet(existing: existing, state: state),
    );
  }
}

// ─── TarefaCard ───────────────────────────────────────────
class _TarefaCard extends StatelessWidget {
  final Tarefa tarefa;
  final AppState state;
  final VoidCallback onEdit;

  const _TarefaCard(
      {required this.tarefa, required this.state, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final cor = AppTheme.corTipo(tarefa.tipo);
    final icone = AppTheme.iconeTipo(tarefa.tipo);
    final xp = AppTheme.calcularXP(tarefa.tipo, tarefa.dificuldade);

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
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: cor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icone, color: cor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tarefa.titulo,
                          style: TextStyle(
                            color: tarefa.concluida
                                ? AppTheme.textMuted
                                : AppTheme.text,
                            fontWeight: FontWeight.w600,
                            decoration: tarefa.concluida
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        Row(
                          children: [
                            _chip(_tipoLabel(tarefa.tipo), cor),
                            const SizedBox(width: 4),
                            _chip(_difLabel(tarefa.dificuldade),
                                AppTheme.textMuted),
                            const SizedBox(width: 4),
                            _chip('+$xp XP', AppTheme.gold),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!tarefa.concluida)
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline_rounded,
                          color: AppTheme.green),
                      onPressed: () => state.concluirTarefa(tarefa),
                    ),
                ],
              ),
              if (tarefa.descricao.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(tarefa.descricao,
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 12)),
                ),
              if (tarefa.delegada && tarefa.delegadoPara.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.person_rounded,
                          color: AppTheme.blue, size: 14),
                      const SizedBox(width: 4),
                      Text('Delegado para: ${tarefa.delegadoPara}',
                          style: const TextStyle(
                              color: AppTheme.blue, fontSize: 12)),
                    ],
                  ),
                ),
              if (tarefa.dataPrazo != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          color: AppTheme.textMuted, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm')
                            .format(tarefa.dataPrazo!),
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              if (!tarefa.concluida)
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: AppTheme.red, size: 18),
                    onPressed: () => state.deletarTarefa(tarefa),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }

  String _tipoLabel(String t) {
    const m = {'comum': 'Comum', 'urgente': 'Urgente', 'importante': 'Importante', 'critica': 'Crítica'};
    return m[t] ?? t;
  }

  String _difLabel(String d) {
    const m = {'facil': 'Fácil', 'medio': 'Médio', 'dificil': 'Difícil', 'epico': 'Épico'};
    return m[d] ?? d;
  }
}

// ─── TarefaFormSheet ──────────────────────────────────────
class TarefaFormSheet extends StatefulWidget {
  final Tarefa? existing;
  final AppState state;
  const TarefaFormSheet({super.key, this.existing, required this.state});

  @override
  State<TarefaFormSheet> createState() => _TarefaFormSheetState();
}

class _TarefaFormSheetState extends State<TarefaFormSheet> {
  final _uuid = const Uuid();
  late final TextEditingController _tituloCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _delegadoCtrl;
  String _tipo = 'comum';
  String _dificuldade = 'medio';
  String _area = 'pessoal';
  bool _delegada = false;
  DateTime? _prazo;
  bool _notificar = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _tituloCtrl = TextEditingController(text: e?.titulo ?? '');
    _descCtrl = TextEditingController(text: e?.descricao ?? '');
    _delegadoCtrl = TextEditingController(text: e?.delegadoPara ?? '');
    if (e != null) {
      _tipo = e.tipo;
      _dificuldade = e.dificuldade;
      _area = e.area;
      _delegada = e.delegada;
      _prazo = e.dataPrazo;
      _notificar = e.notificar;
    }
  }

  @override
  Widget build(BuildContext context) {
    final xp = AppTheme.calcularXP(_tipo, _dificuldade);
    return SingleChildScrollView(
      padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(widget.existing != null ? 'Editar Tarefa' : 'Nova Tarefa',
                  style: const TextStyle(
                      color: AppTheme.text, fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('+$xp XP',
                    style: const TextStyle(
                        color: AppTheme.gold, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _tituloCtrl,
            decoration: const InputDecoration(labelText: 'Título *'),
            style: const TextStyle(color: AppTheme.text),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descCtrl,
            decoration: const InputDecoration(labelText: 'Descrição'),
            style: const TextStyle(color: AppTheme.text),
            maxLines: 2,
          ),
          const SizedBox(height: 12),

          // Tipo (Eisenhower)
          const Text('Tipo', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          const SizedBox(height: 6),
          _segmented(
            options: [('Comum', 'comum'), ('Urgente', 'urgente'),
                ('Importante', 'importante'), ('Crítica', 'critica')],
            selected: _tipo,
            onChanged: (v) => setState(() => _tipo = v),
          ),
          const SizedBox(height: 12),

          // Dificuldade
          const Text('Dificuldade', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          const SizedBox(height: 6),
          _segmented(
            options: [('Fácil', 'facil'), ('Médio', 'medio'),
                ('Difícil', 'dificil'), ('Épico', 'epico')],
            selected: _dificuldade,
            onChanged: (v) => setState(() => _dificuldade = v),
          ),
          const SizedBox(height: 12),

          // Área
          const Text('Área', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8, runSpacing: 6,
            children: [
              ('💼 Trabalho', 'trabalho'), ('🏠 Pessoal', 'pessoal'),
              ('🧘 Saúde', 'saude'), ('📚 Estudos', 'estudos'),
              ('👨‍👩‍👦 Família', 'familia'), ('⚙️ Outro', 'outro'),
            ].map((e) {
              final sel = _area == e.$2;
              return GestureDetector(
                onTap: () => setState(() => _area = e.$2),
                child: Chip(
                  label: Text(e.$1),
                  backgroundColor:
                      sel ? AppTheme.accent.withOpacity(0.2) : AppTheme.card,
                  side: BorderSide(
                      color: sel ? AppTheme.accent : AppTheme.divider),
                  labelStyle: TextStyle(
                      color: sel ? AppTheme.accentLight : AppTheme.textMuted,
                      fontSize: 12),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Delegação
          CheckboxListTile(
            value: _delegada,
            onChanged: (v) => setState(() => _delegada = v ?? false),
            title: const Text('Delegar tarefa',
                style: TextStyle(color: AppTheme.text, fontSize: 13)),
            activeColor: AppTheme.accent,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          if (_delegada) ...[
            TextField(
              controller: _delegadoCtrl,
              decoration: const InputDecoration(labelText: 'Delegar para (nome)'),
              style: const TextStyle(color: AppTheme.text),
            ),
            const SizedBox(height: 12),
          ],

          // Prazo
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today_rounded,
                color: AppTheme.textMuted),
            title: Text(
              _prazo == null
                  ? 'Adicionar prazo'
                  : DateFormat('dd/MM/yyyy HH:mm').format(_prazo!),
              style: TextStyle(
                  color: _prazo == null ? AppTheme.textMuted : AppTheme.text,
                  fontSize: 13),
            ),
            onTap: _pickPrazo,
            trailing: _prazo != null
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded,
                        color: AppTheme.textMuted, size: 16),
                    onPressed: () => setState(() => _prazo = null),
                  )
                : null,
          ),

          // Notificar
          if (_prazo != null)
            CheckboxListTile(
              value: _notificar,
              onChanged: (v) => setState(() => _notificar = v ?? false),
              title: const Text('Notificar 15 min antes',
                  style: TextStyle(color: AppTheme.text, fontSize: 13)),
              activeColor: AppTheme.accent,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _salvar,
              child: Text(widget.existing != null ? 'Salvar' : 'Criar Tarefa (+5 XP)'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _segmented({
    required List<(String, String)> options,
    required String selected,
    required ValueChanged<String> onChanged,
  }) {
    return Row(
      children: options.map((o) {
        final sel = selected == o.$2;
        final color = AppTheme.corTipo(o.$2);
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(o.$2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: sel ? color.withOpacity(0.2) : AppTheme.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: sel ? color : AppTheme.divider,
                    width: sel ? 1.5 : 1),
              ),
              child: Center(
                child: Text(o.$1,
                    style: TextStyle(
                        color: sel ? color : AppTheme.textMuted,
                        fontSize: 11,
                        fontWeight: sel ? FontWeight.bold : FontWeight.normal),
                    overflow: TextOverflow.ellipsis),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _pickPrazo() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (c, w) => Theme(
        data: Theme.of(c).copyWith(
            colorScheme: const ColorScheme.dark(primary: AppTheme.accent)),
        child: w!,
      ),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (c, w) => Theme(
        data: Theme.of(c).copyWith(
            colorScheme: const ColorScheme.dark(primary: AppTheme.accent)),
        child: w!,
      ),
    );
    if (time == null) return;
    setState(() {
      _prazo = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _salvar() async {
    if (_tituloCtrl.text.trim().isEmpty) return;
    if (widget.existing != null) {
      final t = widget.existing!;
      t
        ..titulo = _tituloCtrl.text.trim()
        ..descricao = _descCtrl.text.trim()
        ..tipo = _tipo
        ..dificuldade = _dificuldade
        ..area = _area
        ..delegada = _delegada
        ..delegadoPara = _delegadoCtrl.text.trim()
        ..dataPrazo = _prazo
        ..notificar = _notificar
        ..xpGanho = AppTheme.calcularXP(_tipo, _dificuldade);
      await t.save();
      widget.state.notifyListeners();
    } else {
      await widget.state.adicionarTarefa(
        titulo: _tituloCtrl.text.trim(),
        descricao: _descCtrl.text.trim(),
        tipo: _tipo,
        dificuldade: _dificuldade,
        area: _area,
        delegada: _delegada,
        delegadoPara: _delegadoCtrl.text.trim(),
        dataPrazo: _prazo,
        notificar: _notificar,
      );
    }
    if (context.mounted) Navigator.pop(context);
  }
}
