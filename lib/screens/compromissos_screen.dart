// ═══════════════════════════════════════════════════════════
//  compromissos_screen.dart
// ═══════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class CompromissosScreen extends StatelessWidget {
  const CompromissosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, state, _) {
      final compromissos = state.compromissos;
      return Scaffold(
        backgroundColor: AppTheme.bg,
        appBar: AppBar(title: const Text('📅 Compromissos')),
        body: compromissos.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_rounded, color: AppTheme.textMuted, size: 48),
                    SizedBox(height: 16),
                    Text('Nenhum compromisso agendado',
                        style: TextStyle(color: AppTheme.textMuted)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: compromissos.length,
                itemBuilder: (_, i) => _CompromissoCard(
                  compromisso: compromissos[i],
                  onDelete: () => state.deletarCompromisso(compromissos[i]),
                ),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showDialog(context, state),
          child: const Icon(Icons.add_rounded),
        ),
      );
    });
  }

  void _showDialog(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _CompromissoForm(state: state),
    );
  }
}

class _CompromissoCard extends StatelessWidget {
  final Compromisso compromisso;
  final VoidCallback onDelete;
  const _CompromissoCard({required this.compromisso, required this.onDelete});

  IconData _tipoIcon(String tipo) {
    switch (tipo) {
      case 'medico': return Icons.local_hospital_rounded;
      case 'trabalho': return Icons.work_rounded;
      case 'pessoal': return Icons.person_rounded;
      default: return Icons.event_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cor = Color(
        int.tryParse('0xFF${compromisso.cor.replaceAll('#', '')}') ?? 0xFF7C3AED);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: cor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_tipoIcon(compromisso.tipo), color: cor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(compromisso.titulo,
                      style: const TextStyle(
                          color: AppTheme.text, fontWeight: FontWeight.w600)),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(compromisso.dataHora),
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                  if (compromisso.local.isNotEmpty)
                    Text('📍 ${compromisso.local}',
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 12)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppTheme.red, size: 18),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompromissoForm extends StatefulWidget {
  final AppState state;
  const _CompromissoForm({required this.state});

  @override
  State<_CompromissoForm> createState() => _CompromissoFormState();
}

class _CompromissoFormState extends State<_CompromissoForm> {
  final _uuid = const Uuid();
  final _tituloCtrl = TextEditingController();
  final _localCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  DateTime _dataHora = DateTime.now().add(const Duration(hours: 1));
  String _tipo = 'pessoal';
  bool _notificar = true;
  String _cor = '7C3AED';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Novo Compromisso',
              style: TextStyle(
                  color: AppTheme.text, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _tituloCtrl,
            decoration: const InputDecoration(labelText: 'Título *'),
            style: const TextStyle(color: AppTheme.text),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule_rounded, color: AppTheme.textMuted),
            title: Text(
              DateFormat('dd/MM/yyyy HH:mm').format(_dataHora),
              style: const TextStyle(color: AppTheme.text, fontSize: 13),
            ),
            onTap: _pickDataHora,
          ),
          // Tipo
          const Text('Tipo', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              ('🏥 Médico', 'medico'), ('💼 Trabalho', 'trabalho'),
              ('👤 Pessoal', 'pessoal'), ('⚙️ Outro', 'outro'),
            ].map((e) {
              final sel = _tipo == e.$2;
              return ChoiceChip(
                label: Text(e.$1),
                selected: sel,
                onSelected: (_) => setState(() => _tipo = e.$2),
                selectedColor: AppTheme.accent.withOpacity(0.2),
                backgroundColor: AppTheme.card,
                labelStyle: TextStyle(
                    color: sel ? AppTheme.accentLight : AppTheme.textMuted,
                    fontSize: 12),
                side: BorderSide(
                    color: sel ? AppTheme.accent : AppTheme.divider),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _localCtrl,
            decoration: const InputDecoration(labelText: 'Local'),
            style: const TextStyle(color: AppTheme.text),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notasCtrl,
            decoration: const InputDecoration(labelText: 'Notas'),
            style: const TextStyle(color: AppTheme.text),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: _notificar,
            onChanged: (v) => setState(() => _notificar = v),
            title: const Text('Notificar 15 min antes',
                style: TextStyle(color: AppTheme.text, fontSize: 13)),
            activeColor: AppTheme.accent,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _salvar,
              child: const Text('Agendar Compromisso'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDataHora() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dataHora,
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
      initialTime: TimeOfDay.fromDateTime(_dataHora),
      builder: (c, w) => Theme(
        data: Theme.of(c).copyWith(
            colorScheme: const ColorScheme.dark(primary: AppTheme.accent)),
        child: w!,
      ),
    );
    if (time == null) return;
    setState(() {
      _dataHora =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }


  String _calcularPeriodo(DateTime dt) {
    final h = dt.hour;
    if (h >= 5 && h < 12) return 'manha';
    if (h >= 12 && h < 18) return 'tarde';
    if (h >= 18 && h < 22) return 'noite';
    return 'anytime';
  }

  Future<void> _salvar() async {
    if (_tituloCtrl.text.trim().isEmpty) return;
    final c = Compromisso()
      ..id = _uuid.v4()
      ..titulo = _tituloCtrl.text.trim()
      ..dataHora = _dataHora
      ..local = _localCtrl.text.trim()
      ..notas = _notasCtrl.text.trim()
      ..notificar = _notificar
      ..tipo = _tipo
      ..cor = _cor
      ..periodo = _calcularPeriodo(_dataHora);
    await widget.state.adicionarCompromisso(c);
    if (context.mounted) Navigator.pop(context);
  }
}
