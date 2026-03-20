// ═══════════════════════════════════════════════════════════
//  reunioes_screen.dart
// ═══════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class ReunioesScreen extends StatelessWidget {
  const ReunioesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, state, _) {
      final reunioes = state.reunioes;
      return Scaffold(
        backgroundColor: AppTheme.bg,
        appBar: AppBar(title: const Text('📋 Reuniões')),
        body: reunioes.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.groups_rounded, color: AppTheme.textMuted, size: 48),
                    SizedBox(height: 16),
                    Text('Nenhuma reunião agendada',
                        style: TextStyle(color: AppTheme.textMuted)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: reunioes.length,
                itemBuilder: (_, i) => _ReuniaoCard(
                  reuniao: reunioes[i],
                  onDelete: () => state.deletarReuniao(reunioes[i]),
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
      builder: (_) => _ReuniaoForm(state: state),
    );
  }
}

class _ReuniaoCard extends StatelessWidget {
  final Reuniao reuniao;
  final VoidCallback onDelete;
  const _ReuniaoCard({required this.reuniao, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final cor = Color(
        int.tryParse('0xFF${reuniao.cor.replaceAll('#', '')}') ?? 0xFF3B82F6);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 4, height: 60,
              decoration: BoxDecoration(
                  color: cor, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reuniao.titulo,
                      style: const TextStyle(
                          color: AppTheme.text, fontWeight: FontWeight.w600)),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(reuniao.dataHora) +
                        ' · ${reuniao.duracaoMinutos} min',
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 12),
                  ),
                  if (reuniao.local.isNotEmpty)
                    Text('📍 ${reuniao.local}',
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 12)),
                  if (reuniao.participantes.isNotEmpty)
                    Text('👥 ${reuniao.participantes}',
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

class _ReuniaoForm extends StatefulWidget {
  final AppState state;
  const _ReuniaoForm({required this.state});

  @override
  State<_ReuniaoForm> createState() => _ReuniaoFormState();
}

class _ReuniaoFormState extends State<_ReuniaoForm> {
  final _uuid = const Uuid();
  final _tituloCtrl = TextEditingController();
  final _localCtrl = TextEditingController();
  final _partCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  DateTime _dataHora = DateTime.now().add(const Duration(hours: 1));
  int _duracao = 60;
  bool _notificar = true;
  String _cor = '3B82F6';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Nova Reunião',
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
          TextField(
            decoration: const InputDecoration(labelText: 'Duração (min)'),
            style: const TextStyle(color: AppTheme.text),
            keyboardType: TextInputType.number,
            onChanged: (v) => _duracao = int.tryParse(v) ?? 60,
            controller: TextEditingController(text: '$_duracao'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _localCtrl,
            decoration: const InputDecoration(labelText: 'Local'),
            style: const TextStyle(color: AppTheme.text),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _partCtrl,
            decoration: const InputDecoration(labelText: 'Participantes'),
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
              child: const Text('Agendar Reunião'),
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

  Future<void> _salvar() async {
    if (_tituloCtrl.text.trim().isEmpty) return;
    final r = Reuniao()
      ..id = _uuid.v4()
      ..titulo = _tituloCtrl.text.trim()
      ..dataHora = _dataHora
      ..duracaoMinutos = _duracao
      ..local = _localCtrl.text.trim()
      ..participantes = _partCtrl.text.trim()
      ..notas = _notasCtrl.text.trim()
      ..notificar = _notificar
      ..cor = _cor;
    await widget.state.adicionarReuniao(r);
    if (context.mounted) Navigator.pop(context);
  }
}
