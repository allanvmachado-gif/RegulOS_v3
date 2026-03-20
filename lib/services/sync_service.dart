// ═══════════════════════════════════════════════════════════
//  sync_service.dart — Firebase Firestore sync bidirecional
// ═══════════════════════════════════════════════════════════
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/models.dart';

class SyncService {
  SyncService._();
  static final SyncService instance = SyncService._();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _col(String name) =>
      _db.collection('users').doc(uid).collection(name);

  // ─── Upload completo para o Firestore ───────────────────
  Future<void> uploadAll() async {
    if (uid == null) return;
    try {
      await Future.wait([
        _uploadTarefas(),
        _uploadBlocos(),
        _uploadCheckins(),
        _uploadReunioes(),
        _uploadCompromissos(),
        _uploadDiario(),
        _uploadPerfil(),
      ]);
      debugPrint('✅ Sync upload completo');
    } catch (e) {
      debugPrint('⚠️ Erro no upload: $e');
    }
  }

  // ─── Download do Firestore para Hive ────────────────────
  Future<void> downloadAll() async {
    if (uid == null) return;
    try {
      await Future.wait([
        _downloadTarefas(),
        _downloadBlocos(),
        _downloadCheckins(),
        _downloadReunioes(),
        _downloadCompromissos(),
        _downloadDiario(),
        _downloadPerfil(),
      ]);
      debugPrint('✅ Sync download completo');
    } catch (e) {
      debugPrint('⚠️ Erro no download: $e');
    }
  }

  // ─── Tarefas ─────────────────────────────────────────────
  Future<void> _uploadTarefas() async {
    final box = Hive.box<Tarefa>('tarefas');
    final batch = _db.batch();
    for (final t in box.values) {
      batch.set(_col('tarefas').doc(t.id), {
        'id': t.id, 'titulo': t.titulo, 'descricao': t.descricao,
        'tipo': t.tipo, 'dificuldade': t.dificuldade, 'area': t.area,
        'concluida': t.concluida, 'delegada': t.delegada,
        'delegadoPara': t.delegadoPara,
        'dataPrazo': t.dataPrazo?.toIso8601String(),
        'criadaEm': t.criadaEm.toIso8601String(),
        'concluidaEm': t.concluidaEm?.toIso8601String(),
        'xpGanho': t.xpGanho, 'notificar': t.notificar,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<void> _downloadTarefas() async {
    final snap = await _col('tarefas').get();
    final box = Hive.box<Tarefa>('tarefas');
    await box.clear();
    for (final doc in snap.docs) {
      final d = doc.data();
      final t = Tarefa()
        ..id = d['id'] ?? doc.id
        ..titulo = d['titulo'] ?? ''
        ..descricao = d['descricao'] ?? ''
        ..tipo = d['tipo'] ?? 'comum'
        ..dificuldade = d['dificuldade'] ?? 'medio'
        ..area = d['area'] ?? 'pessoal'
        ..concluida = d['concluida'] ?? false
        ..delegada = d['delegada'] ?? false
        ..delegadoPara = d['delegadoPara'] ?? ''
        ..dataPrazo = d['dataPrazo'] != null ? DateTime.tryParse(d['dataPrazo']) : null
        ..criadaEm = d['criadaEm'] != null ? DateTime.parse(d['criadaEm']) : DateTime.now()
        ..concluidaEm = d['concluidaEm'] != null ? DateTime.tryParse(d['concluidaEm']) : null
        ..xpGanho = d['xpGanho'] ?? 15
        ..notificar = d['notificar'] ?? false;
      await box.add(t);
    }
  }

  // ─── Blocos de Rotina ────────────────────────────────────
  Future<void> _uploadBlocos() async {
    final box = Hive.box<BlocoRotina>('blocos');
    final batch = _db.batch();
    for (final b in box.values) {
      batch.set(_col('blocos').doc(b.id), {
        'id': b.id, 'titulo': b.titulo, 'horarioInicio': b.horarioInicio,
        'horarioFim': b.horarioFim, 'icone': b.icone, 'cor': b.cor,
        'diasSemana': b.diasSemana, 'ativo': b.ativo,
        'descricao': b.descricao, 'notificar': b.notificar,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<void> _downloadBlocos() async {
    final snap = await _col('blocos').get();
    final box = Hive.box<BlocoRotina>('blocos');
    await box.clear();
    for (final doc in snap.docs) {
      final d = doc.data();
      final b = BlocoRotina()
        ..id = d['id'] ?? doc.id
        ..titulo = d['titulo'] ?? ''
        ..horarioInicio = d['horarioInicio'] ?? '08:00'
        ..horarioFim = d['horarioFim'] ?? '09:00'
        ..icone = d['icone'] ?? '📌'
        ..cor = d['cor'] ?? '7C3AED'
        ..diasSemana = List<int>.from(d['diasSemana'] ?? [1,2,3,4,5])
        ..ativo = d['ativo'] ?? true
        ..descricao = d['descricao'] ?? ''
        ..notificar = d['notificar'] ?? false;
      await box.add(b);
    }
  }

  // ─── CheckIns ────────────────────────────────────────────
  Future<void> _uploadCheckins() async {
    final box = Hive.box<CheckIn>('checkins');
    final batch = _db.batch();
    for (final c in box.values) {
      batch.set(_col('checkins').doc(c.id), {
        'id': c.id, 'blocoId': c.blocoId, 'data': c.data,
        'status': c.status,
        'registradoEm': c.registradoEm.toIso8601String(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<void> _downloadCheckins() async {
    final snap = await _col('checkins').get();
    final box = Hive.box<CheckIn>('checkins');
    await box.clear();
    for (final doc in snap.docs) {
      final d = doc.data();
      final c = CheckIn()
        ..id = d['id'] ?? doc.id
        ..blocoId = d['blocoId'] ?? ''
        ..data = d['data'] ?? ''
        ..status = d['status'] ?? 'feito'
        ..registradoEm = d['registradoEm'] != null
            ? DateTime.parse(d['registradoEm'])
            : DateTime.now();
      await box.add(c);
    }
  }

  // ─── Reuniões ────────────────────────────────────────────
  Future<void> _uploadReunioes() async {
    final box = Hive.box<Reuniao>('reunioes');
    final batch = _db.batch();
    for (final r in box.values) {
      batch.set(_col('reunioes').doc(r.id), {
        'id': r.id, 'titulo': r.titulo,
        'dataHora': r.dataHora.toIso8601String(),
        'duracaoMinutos': r.duracaoMinutos, 'local': r.local,
        'participantes': r.participantes, 'notas': r.notas,
        'notificar': r.notificar, 'cor': r.cor,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<void> _downloadReunioes() async {
    final snap = await _col('reunioes').get();
    final box = Hive.box<Reuniao>('reunioes');
    await box.clear();
    for (final doc in snap.docs) {
      final d = doc.data();
      final r = Reuniao()
        ..id = d['id'] ?? doc.id
        ..titulo = d['titulo'] ?? ''
        ..dataHora = DateTime.parse(d['dataHora'])
        ..duracaoMinutos = d['duracaoMinutos'] ?? 60
        ..local = d['local'] ?? ''
        ..participantes = d['participantes'] ?? ''
        ..notas = d['notas'] ?? ''
        ..notificar = d['notificar'] ?? false
        ..cor = d['cor'] ?? '3B82F6';
      await box.add(r);
    }
  }

  // ─── Compromissos ────────────────────────────────────────
  Future<void> _uploadCompromissos() async {
    final box = Hive.box<Compromisso>('compromissos');
    final batch = _db.batch();
    for (final c in box.values) {
      batch.set(_col('compromissos').doc(c.id), {
        'id': c.id, 'titulo': c.titulo,
        'dataHora': c.dataHora.toIso8601String(),
        'local': c.local, 'notas': c.notas,
        'notificar': c.notificar, 'tipo': c.tipo, 'cor': c.cor,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<void> _downloadCompromissos() async {
    final snap = await _col('compromissos').get();
    final box = Hive.box<Compromisso>('compromissos');
    await box.clear();
    for (final doc in snap.docs) {
      final d = doc.data();
      final c = Compromisso()
        ..id = d['id'] ?? doc.id
        ..titulo = d['titulo'] ?? ''
        ..dataHora = DateTime.parse(d['dataHora'])
        ..local = d['local'] ?? ''
        ..notas = d['notas'] ?? ''
        ..notificar = d['notificar'] ?? false
        ..tipo = d['tipo'] ?? 'pessoal'
        ..cor = d['cor'] ?? '7C3AED';
      await box.add(c);
    }
  }

  // ─── Diário ──────────────────────────────────────────────
  Future<void> _uploadDiario() async {
    final box = Hive.box<EntradaDiario>('diario');
    final batch = _db.batch();
    for (final e in box.values) {
      batch.set(_col('diario').doc(e.id), {
        'id': e.id, 'data': e.data, 'conteudo': e.conteudo,
        'humor': e.humor, 'criadoEm': e.criadoEm.toIso8601String(),
        'energiaNivel': e.energiaNivel,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<void> _downloadDiario() async {
    final snap = await _col('diario').get();
    final box = Hive.box<EntradaDiario>('diario');
    await box.clear();
    for (final doc in snap.docs) {
      final d = doc.data();
      final e = EntradaDiario()
        ..id = d['id'] ?? doc.id
        ..data = d['data'] ?? ''
        ..conteudo = d['conteudo'] ?? ''
        ..humor = d['humor'] ?? 'neutro'
        ..criadoEm = d['criadoEm'] != null
            ? DateTime.parse(d['criadoEm'])
            : DateTime.now()
        ..energiaNivel = d['energiaNivel'] ?? 5;
      await box.add(e);
    }
  }

  // ─── Perfil ──────────────────────────────────────────────
  Future<void> _uploadPerfil() async {
    final box = Hive.box<Perfil>('perfil');
    if (box.isEmpty) return;
    final p = box.getAt(0)!;
    await _col('perfil').doc('main').set({
      'nome': p.nome, 'descricao': p.descricao,
      'xpTotal': p.xpTotal, 'nivel': p.nivel,
      'streakAtual': p.streakAtual, 'streakMaximo': p.streakMaximo,
      'ultimoCheckin': p.ultimoCheckin?.toIso8601String(),
      'totalTarefasConcluidas': p.totalTarefasConcluidas,
      'totalBlocosFeitos': p.totalBlocosFeitos,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _downloadPerfil() async {
    final doc = await _col('perfil').doc('main').get();
    if (!doc.exists) return;
    final d = doc.data()!;
    final box = Hive.box<Perfil>('perfil');
    final p = box.isEmpty ? (Perfil()..fotoPath = null) : box.getAt(0)!;
    p
      ..nome = d['nome'] ?? 'Allan Vinicius'
      ..descricao = d['descricao'] ?? ''
      ..xpTotal = d['xpTotal'] ?? 0
      ..nivel = d['nivel'] ?? 1
      ..streakAtual = d['streakAtual'] ?? 0
      ..streakMaximo = d['streakMaximo'] ?? 0
      ..ultimoCheckin = d['ultimoCheckin'] != null
          ? DateTime.tryParse(d['ultimoCheckin'])
          : null
      ..totalTarefasConcluidas = d['totalTarefasConcluidas'] ?? 0
      ..totalBlocosFeitos = d['totalBlocosFeitos'] ?? 0;
    if (box.isEmpty) await box.add(p); else await p.save();
  }

  // ─── Sync automático a cada operação ────────────────────
  Future<void> syncItem(String collection, String docId, Map<String, dynamic> data) async {
    if (uid == null) return;
    try {
      await _col(collection).doc(docId).set({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Sync item error: $e');
    }
  }

  Future<void> deleteItem(String collection, String docId) async {
    if (uid == null) return;
    try {
      await _col(collection).doc(docId).delete();
    } catch (e) {
      debugPrint('Delete item error: $e');
    }
  }
}
