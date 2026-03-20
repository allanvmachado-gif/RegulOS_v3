// ═══════════════════════════════════════════════════════════
//  app_state.dart — com Firebase Auth + Firestore sync
// ═══════════════════════════════════════════════════════════
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import 'notification_service.dart';
import 'sync_service.dart';

class AppState extends ChangeNotifier {
  final _uuid = const Uuid();
  final bool firebaseDisponivel;
  late final FirebaseAuth? _auth;
  late final GoogleSignIn? _googleSignIn;
  DateTime _dataSelecionada = DateTime.now();

  AppState({this.firebaseDisponivel = true}) {
    if (firebaseDisponivel) {
      _auth = FirebaseAuth.instance;
      _googleSignIn = GoogleSignIn();
    } else {
      _auth = null;
      _googleSignIn = null;
    }
  }

  DateTime get dataSelecionada => _dataSelecionada;

  // Auth state stream
  Stream<User?> get authStateChanges =>
      firebaseDisponivel ? _auth!.authStateChanges() : const Stream.empty();
  User? get currentUser => firebaseDisponivel ? _auth?.currentUser : null;
  bool get isLoggedIn => currentUser != null;

  // ─── Login Google ────────────────────────────────────────
  Future<void> signInWithGoogle() async {
    if (!firebaseDisponivel) return;
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        await _auth!.signInWithPopup(provider);
      } else {
        final googleUser = await _googleSignIn!.signIn();
        if (googleUser == null) return;
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await _auth!.signInWithCredential(credential);
      }
      await SyncService.instance.downloadAll();
      notifyListeners();
    } catch (e) {
      debugPrint('Erro login Google: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (!firebaseDisponivel) return;
    await SyncService.instance.uploadAll();
    await _auth!.signOut();
    if (!kIsWeb) await _googleSignIn!.signOut();
    notifyListeners();
  }

  // ─── Sync manual ────────────────────────────────────────
  Future<void> sincronizarAgora() async {
    await SyncService.instance.uploadAll();
    await SyncService.instance.downloadAll();
    notifyListeners();
  }

  // ─── Boxes Hive ─────────────────────────────────────────
  Box<Tarefa> get boxTarefas => Hive.box<Tarefa>('tarefas');
  Box<BlocoRotina> get boxBlocos => Hive.box<BlocoRotina>('blocos');
  Box<CheckIn> get boxCheckins => Hive.box<CheckIn>('checkins');
  Box<Reuniao> get boxReunioes => Hive.box<Reuniao>('reunioes');
  Box<Compromisso> get boxCompromissos => Hive.box<Compromisso>('compromissos');
  Box<EntradaDiario> get boxDiario => Hive.box<EntradaDiario>('diario');
  Box<Conquista> get boxConquistas => Hive.box<Conquista>('conquistas');
  Box<Perfil> get boxPerfil => Hive.box<Perfil>('perfil');
  Box<AvaliacaoMatinal> get boxAvaliacoes => Hive.box<AvaliacaoMatinal>('avaliacoes');
  Box<AtividadeRecarga> get boxRecargas => Hive.box<AtividadeRecarga>('recargas');
  Box get boxConfig => Hive.box('config');

  // ─── Avaliação Matinal ──────────────────────────────────
  AvaliacaoMatinal? getAvaliacaoMatinal(String dataChaveParam) {
    try {
      return boxAvaliacoes.values
          .cast<AvaliacaoMatinal?>()
          .firstWhere((a) => a?.data == dataChaveParam, orElse: () => null);
    } catch (_) {
      return null;
    }
  }

  Future<void> salvarAvaliacaoMatinal(AvaliacaoMatinal avaliacao) async {
    // Remove avaliação anterior do mesmo dia se existir
    final existente = getAvaliacaoMatinal(avaliacao.data);
    if (existente != null) await existente.delete();
    await boxAvaliacoes.add(avaliacao);
    notifyListeners();
  }

  // ─── Atividades de Recarga (catálogo) ────────────────────
  List<AtividadeRecarga> get recargasHoje {
    // Retorna todas as atividades ativas do catálogo
    final lista = boxRecargas.values.where((r) => r.ativa).toList();
    // Se vazio, inicializa com padrões
    if (lista.isEmpty) _inicializarAtividadesPadrao();
    return boxRecargas.values.where((r) => r.ativa).toList();
  }

  void _inicializarAtividadesPadrao() {
    const padroes = [
      ('stim-01', 'Stimming', '🔄', 10),
      ('terapia-01', 'Terapia', '🧠', 25),
      ('meditacao-01', 'Meditação', '🧘', 15),
      ('esporte-01', 'Exercício', '🏃', 20),
      ('lazer-01', 'Lazer', '🎮', 12),
      ('social-01', 'Conversa de conforto', '💬', 15),
      ('natureza-01', 'Contato com natureza', '🌿', 10),
      ('descanso-01', 'Descanso', '😴', 18),
    ];
    for (final p in padroes) {
      final a = AtividadeRecarga()
        ..id = p.$1
        ..nome = p.$2
        ..icone = p.$3
        ..pontosRecuperacao = p.$4
        ..ativa = true
        ..personalizada = false;
      boxRecargas.put(p.$1, a);
    }
  }

  Future<void> adicionarRecarga(AtividadeRecarga recarga) async {
    await boxRecargas.put(recarga.id, recarga);
    notifyListeners();
  }

  // ─── Perfil ──────────────────────────────────────────────
  Perfil get perfil {
    if (boxPerfil.isEmpty) {
      final p = Perfil()
        ..nome = currentUser?.displayName ?? 'Allan Vinicius'
        ..descricao = 'Minha agenda pessoal'
        ..xpTotal = 0
        ..nivel = 1
        ..streakAtual = 0
        ..streakMaximo = 0
        ..fotoPath = null
        ..ultimoCheckin = null
        ..totalTarefasConcluidas = 0
        ..totalBlocosFeitos = 0;
      boxPerfil.add(p);
      return p;
    }
    return boxPerfil.getAt(0)!;
  }

  void _salvarPerfil(Perfil p) {
    p.save();
    SyncService.instance.syncItem('perfil', 'main', {
      'nome': p.nome, 'xpTotal': p.xpTotal, 'nivel': p.nivel,
      'streakAtual': p.streakAtual, 'streakMaximo': p.streakMaximo,
      'ultimoCheckin': p.ultimoCheckin?.toIso8601String(),
      'totalTarefasConcluidas': p.totalTarefasConcluidas,
      'totalBlocosFeitos': p.totalBlocosFeitos,
    });
    notifyListeners();
  }

  // ─── Navegação de data ───────────────────────────────────
  void setDataSelecionada(DateTime d) {
    _dataSelecionada = DateTime(d.year, d.month, d.day);
    notifyListeners();
  }
  void avancarDia() => setDataSelecionada(_dataSelecionada.add(const Duration(days: 1)));
  void voltarDia() => setDataSelecionada(_dataSelecionada.subtract(const Duration(days: 1)));
  void irParaHoje() => setDataSelecionada(DateTime.now());

  // ─── Tarefas/Reuniões/Compromissos por período ───────────────
  List<Tarefa> tarefasNoPeriodo(String periodo, String dataChaveParam) {
    return boxTarefas.values.where((t) {
      final mesmaData = t.dataPrazo != null &&
          DateFormat('yyyy-MM-dd').format(t.dataPrazo!) == dataChaveParam;
      final criadaNaData = DateFormat('yyyy-MM-dd').format(t.criadaEm) == dataChaveParam;
      return (mesmaData || criadaNaData) &&
          (periodo == 'anytime' || t.periodo == periodo);
    }).toList();
  }

  List<Reuniao> reunioesNoPeriodo(String periodo, String dataChaveParam) {
    return boxReunioes.values.where((r) {
      final dataR = DateFormat('yyyy-MM-dd').format(r.dataHora);
      if (dataR != dataChaveParam) return false;
      if (periodo == 'anytime') return true;
      final h = r.dataHora.hour;
      switch (periodo) {
        case 'manha': return h >= 5 && h < 12;
        case 'tarde': return h >= 12 && h < 18;
        case 'noite': return h >= 18;
        default: return true;
      }
    }).toList();
  }

  List<Compromisso> compromissosNoPeriodo(String periodo, String dataChaveParam) {
    return boxCompromissos.values.where((c) {
      final dataC = DateFormat('yyyy-MM-dd').format(c.dataHora);
      if (dataC != dataChaveParam) return false;
      if (periodo == 'anytime') return true;
      final h = c.dataHora.hour;
      switch (periodo) {
        case 'manha': return h >= 5 && h < 12;
        case 'tarde': return h >= 12 && h < 18;
        case 'noite': return h >= 18;
        default: return true;
      }
    }).toList();
  }

  // ─── Atividades de Recarga (getter público) ───────────────────
  List<AtividadeRecarga> get atividadesRecarga =>
      boxRecargas.values.toList();

  Future<void> registrarRecarga(AtividadeRecarga recarga) async {
    await adicionarRecarga(recarga);
  }

  // ─── salvarAvaliacaoMatinal (assinatura nomeada) ────────────
  Future<void> salvarAvaliacaoMatinalNomeada({
    required int qualidadeSono,
    required int humor,
    required int energiaFisica,
    required int nivelStress,
    required bool dorFisica,
    required int bateriaInicial,
    String observacoes = '',
  }) async {
    final av = AvaliacaoMatinal()
      ..id = const Uuid().v4()
      ..data = dataChave
      ..qualidadeSono = qualidadeSono
      ..humor = humor
      ..energiaFisica = energiaFisica
      ..nivelStress = nivelStress
      ..dorFisica = dorFisica
      ..bateriaInicial = bateriaInicial
      ..bateriaRestante = bateriaInicial
      ..ganhoTotal = 0
      ..custoTotal = 0
      ..observacoes = observacoes
      ..bateriaIniciada = bateriaInicial
      ..timestamp = DateTime.now();
    await salvarAvaliacaoMatinal(av);
  }

  String get dataFormatada =>
      DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(_dataSelecionada);
  String get dataChave => DateFormat('yyyy-MM-dd').format(_dataSelecionada);
  bool get isHoje {
    final hoje = DateTime.now();
    return _dataSelecionada.year == hoje.year &&
        _dataSelecionada.month == hoje.month &&
        _dataSelecionada.day == hoje.day;
  }

  // ─── Blocos de Rotina ────────────────────────────────────
  List<BlocoRotina> get blocosAtivos {
    final diaSemana = _dataSelecionada.weekday;
    return boxBlocos.values
        .where((b) => b.ativo && b.diasSemana.contains(diaSemana))
        .toList()
      ..sort((a, b) => a.horarioInicio.compareTo(b.horarioInicio));
  }

  Future<void> adicionarBloco(BlocoRotina bloco) async {
    await boxBlocos.add(bloco);
    if (!kIsWeb && bloco.notificar) _agendarNotificacaoBloco(bloco);
    await SyncService.instance.syncItem('blocos', bloco.id, {
      'id': bloco.id, 'titulo': bloco.titulo, 'horarioInicio': bloco.horarioInicio,
      'horarioFim': bloco.horarioFim, 'icone': bloco.icone, 'cor': bloco.cor,
      'diasSemana': bloco.diasSemana, 'ativo': bloco.ativo,
      'descricao': bloco.descricao, 'notificar': bloco.notificar,
    });
    notifyListeners();
  }

  Future<void> editarBloco(BlocoRotina bloco) async {
    await bloco.save();
    if (!kIsWeb) {
      NotificationService.instance.cancel(NotificationService.hashId(bloco.id));
      if (bloco.notificar) _agendarNotificacaoBloco(bloco);
    }
    await SyncService.instance.syncItem('blocos', bloco.id, {
      'titulo': bloco.titulo, 'horarioInicio': bloco.horarioInicio,
      'horarioFim': bloco.horarioFim, 'ativo': bloco.ativo,
    });
    notifyListeners();
  }

  Future<void> deletarBloco(BlocoRotina bloco) async {
    if (!kIsWeb) NotificationService.instance.cancel(NotificationService.hashId(bloco.id));
    await SyncService.instance.deleteItem('blocos', bloco.id);
    await bloco.delete();
    notifyListeners();
  }

  void _agendarNotificacaoBloco(BlocoRotina bloco) {
    final parts = bloco.horarioInicio.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    NotificationService.instance.scheduleDailyNotification(
      id: NotificationService.hashId(bloco.id),
      title: '${bloco.icone} ${bloco.titulo}',
      body: 'Hora de começar! ${bloco.horarioInicio}',
      hour: h,
      minute: m,
    );
  }

  // ─── Check-in ────────────────────────────────────────────
  CheckIn? getCheckIn(String blocoId, String data) {
    try {
      return boxCheckins.values.firstWhere(
          (c) => c.blocoId == blocoId && c.data == data);
    } catch (_) {
      return null;
    }
  }

  Future<void> registrarCheckIn(String blocoId, String status) async {
    final data = dataChave;
    final existing = getCheckIn(blocoId, data);
    final id = existing?.id ?? _uuid.v4();
    if (existing != null) {
      existing.status = status;
      existing.registradoEm = DateTime.now();
      await existing.save();
    } else {
      final ci = CheckIn()
        ..id = id
        ..blocoId = blocoId
        ..data = data
        ..status = status
        ..registradoEm = DateTime.now();
      await boxCheckins.add(ci);
    }
    await SyncService.instance.syncItem('checkins', id, {
      'id': id, 'blocoId': blocoId, 'data': data, 'status': status,
      'registradoEm': DateTime.now().toIso8601String(),
    });
    await _atualizarXpCheckIn(status);
    await _verificarStreak();
    await _verificarConquistas();
    notifyListeners();
  }

  Future<void> _atualizarXpCheckIn(String status) async {
    final p = perfil;
    int xp = 0;
    if (status == 'feito') xp = 10;
    else if (status == 'parcial') xp = 5;
    p.xpTotal += xp;
    p.totalBlocosFeitos += (status == 'feito' ? 1 : 0);
    p.nivel = AppTheme.calcularNivel(p.xpTotal);
    _salvarPerfil(p);
  }

  // ─── Score do dia ────────────────────────────────────────
  double calcularScoreDia(String data) {
    final diaSemana = _parseDiaFromData(data);
    final blocosNoDia = boxBlocos.values
        .where((b) => b.ativo && b.diasSemana.contains(diaSemana))
        .toList();
    if (blocosNoDia.isEmpty) return 0;
    double total = 0;
    for (final b in blocosNoDia) {
      final ci = getCheckIn(b.id, data);
      if (ci == null) continue;
      if (ci.status == 'feito') total += 1.0;
      else if (ci.status == 'parcial') total += 0.5;
    }
    return total / blocosNoDia.length;
  }

  int _parseDiaFromData(String data) {
    try { return DateTime.parse(data).weekday; } catch (_) { return 1; }
  }

  double get scoreDiaAtual => calcularScoreDia(dataChave);

  // ─── Streak ──────────────────────────────────────────────
  Future<void> _verificarStreak() async {
    final p = perfil;
    final hoje = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final ontem = DateFormat('yyyy-MM-dd').format(
        DateTime.now().subtract(const Duration(days: 1)));
    if (p.ultimoCheckin == null) {
      p.streakAtual = 1;
      p.ultimoCheckin = DateTime.now();
    } else {
      final ultimo = DateFormat('yyyy-MM-dd').format(p.ultimoCheckin!);
      if (ultimo == hoje) {
        // já contou
      } else if (ultimo == ontem) {
        p.streakAtual++;
        p.ultimoCheckin = DateTime.now();
        if (p.streakAtual % 3 == 0) p.xpTotal += 30;
      } else {
        p.streakAtual = 1;
        p.ultimoCheckin = DateTime.now();
      }
    }
    if (p.streakAtual > p.streakMaximo) p.streakMaximo = p.streakAtual;
    p.nivel = AppTheme.calcularNivel(p.xpTotal);
    _salvarPerfil(p);
  }

  // ─── Tarefas ─────────────────────────────────────────────
  List<Tarefa> get tarefasPendentes => boxTarefas.values
      .where((t) => !t.concluida).toList()
    ..sort((a, b) => _prio(b.tipo).compareTo(_prio(a.tipo)));

  List<Tarefa> get tarefasConcluidas => boxTarefas.values
      .where((t) => t.concluida).toList()
    ..sort((a, b) => (b.concluidaEm ?? DateTime.now())
        .compareTo(a.concluidaEm ?? DateTime.now()));

  int _prio(String tipo) {
    const m = {'critica': 4, 'importante': 3, 'urgente': 2, 'comum': 1};
    return m[tipo] ?? 1;
  }

  Future<Tarefa> adicionarTarefa({
    required String titulo,
    String descricao = '',
    String tipo = 'comum',
    String dificuldade = 'medio',
    String area = 'pessoal',
    bool delegada = false,
    String delegadoPara = '',
    DateTime? dataPrazo,
    bool notificar = false,
  }) async {
    final xp = AppTheme.calcularXP(tipo, dificuldade);
    final t = Tarefa()
      ..id = _uuid.v4()
      ..titulo = titulo
      ..descricao = descricao
      ..tipo = tipo
      ..dificuldade = dificuldade
      ..area = area
      ..concluida = false
      ..delegada = delegada
      ..delegadoPara = delegadoPara
      ..dataPrazo = dataPrazo
      ..criadaEm = DateTime.now()
      ..concluidaEm = null
      ..xpGanho = xp
      ..notificar = notificar;
    await boxTarefas.add(t);

    final p = perfil;
    p.xpTotal += 5;
    if (delegada) p.xpTotal += 3;
    p.nivel = AppTheme.calcularNivel(p.xpTotal);
    _salvarPerfil(p);

    if (!kIsWeb && notificar && dataPrazo != null) {
      await NotificationService.instance.scheduleNotification(
        id: NotificationService.hashId(t.id),
        title: '⏰ ${t.titulo}',
        body: 'Tarefa em 15 minutos!',
        scheduledDate: dataPrazo.subtract(const Duration(minutes: 15)),
        high: tipo == 'critica' || tipo == 'urgente',
      );
    }

    await SyncService.instance.syncItem('tarefas', t.id, {
      'id': t.id, 'titulo': t.titulo, 'descricao': t.descricao,
      'tipo': t.tipo, 'dificuldade': t.dificuldade, 'area': t.area,
      'concluida': false, 'delegada': t.delegada,
      'delegadoPara': t.delegadoPara,
      'dataPrazo': t.dataPrazo?.toIso8601String(),
      'criadaEm': t.criadaEm.toIso8601String(),
      'xpGanho': t.xpGanho, 'notificar': t.notificar,
    });
    notifyListeners();
    return t;
  }

  Future<void> concluirTarefa(Tarefa t) async {
    t.concluida = true;
    t.concluidaEm = DateTime.now();
    await t.save();
    final p = perfil;
    p.xpTotal += t.xpGanho;
    p.totalTarefasConcluidas++;
    p.nivel = AppTheme.calcularNivel(p.xpTotal);
    _salvarPerfil(p);
    if (!kIsWeb) NotificationService.instance.cancel(NotificationService.hashId(t.id));
    await SyncService.instance.syncItem('tarefas', t.id, {
      'concluida': true,
      'concluidaEm': t.concluidaEm!.toIso8601String(),
    });
    await _verificarConquistas();
    notifyListeners();
  }

  Future<void> deletarTarefa(Tarefa t) async {
    if (!kIsWeb) NotificationService.instance.cancel(NotificationService.hashId(t.id));
    await SyncService.instance.deleteItem('tarefas', t.id);
    await t.delete();
    notifyListeners();
  }

  // ─── Reuniões ────────────────────────────────────────────
  List<Reuniao> get reunioes => boxReunioes.values.toList()
    ..sort((a, b) => a.dataHora.compareTo(b.dataHora));

  Future<void> adicionarReuniao(Reuniao r) async {
    await boxReunioes.add(r);
    if (!kIsWeb && r.notificar) {
      await NotificationService.instance.scheduleNotification(
        id: NotificationService.hashId(r.id),
        title: '📋 ${r.titulo}',
        body: 'Reunião em 15 minutos',
        scheduledDate: r.dataHora.subtract(const Duration(minutes: 15)),
      );
    }
    await SyncService.instance.syncItem('reunioes', r.id, {
      'id': r.id, 'titulo': r.titulo, 'dataHora': r.dataHora.toIso8601String(),
      'duracaoMinutos': r.duracaoMinutos, 'local': r.local,
      'participantes': r.participantes, 'notas': r.notas,
      'notificar': r.notificar, 'cor': r.cor,
    });
    notifyListeners();
  }

  Future<void> deletarReuniao(Reuniao r) async {
    if (!kIsWeb) NotificationService.instance.cancel(NotificationService.hashId(r.id));
    await SyncService.instance.deleteItem('reunioes', r.id);
    await r.delete();
    notifyListeners();
  }

  // ─── Compromissos ────────────────────────────────────────
  List<Compromisso> get compromissos => boxCompromissos.values.toList()
    ..sort((a, b) => a.dataHora.compareTo(b.dataHora));

  Future<void> adicionarCompromisso(Compromisso c) async {
    await boxCompromissos.add(c);
    if (!kIsWeb && c.notificar) {
      await NotificationService.instance.scheduleNotification(
        id: NotificationService.hashId(c.id),
        title: '📅 ${c.titulo}',
        body: 'Compromisso em 15 minutos',
        scheduledDate: c.dataHora.subtract(const Duration(minutes: 15)),
      );
    }
    await SyncService.instance.syncItem('compromissos', c.id, {
      'id': c.id, 'titulo': c.titulo, 'dataHora': c.dataHora.toIso8601String(),
      'local': c.local, 'notas': c.notas, 'notificar': c.notificar,
      'tipo': c.tipo, 'cor': c.cor,
    });
    notifyListeners();
  }

  Future<void> deletarCompromisso(Compromisso c) async {
    if (!kIsWeb) NotificationService.instance.cancel(NotificationService.hashId(c.id));
    await SyncService.instance.deleteItem('compromissos', c.id);
    await c.delete();
    notifyListeners();
  }

  // ─── Diário ──────────────────────────────────────────────
  EntradaDiario? getEntradaDiario(String data) {
    try { return boxDiario.values.firstWhere((e) => e.data == data); }
    catch (_) { return null; }
  }

  Future<void> salvarEntradaDiario(EntradaDiario entrada) async {
    final existing = getEntradaDiario(entrada.data);
    if (existing != null) {
      existing.conteudo = entrada.conteudo;
      existing.humor = entrada.humor;
      existing.energiaNivel = entrada.energiaNivel;
      await existing.save();
    } else {
      await boxDiario.add(entrada);
    }
    await SyncService.instance.syncItem('diario', entrada.id, {
      'id': entrada.id, 'data': entrada.data, 'conteudo': entrada.conteudo,
      'humor': entrada.humor, 'energiaNivel': entrada.energiaNivel,
      'criadoEm': entrada.criadoEm.toIso8601String(),
    });
    notifyListeners();
  }

  // ─── Conquistas ──────────────────────────────────────────
  Future<void> inicializarConquistas() async {
    if (boxConquistas.isNotEmpty) return;
    final lista = [
      _mkC('primeira_marca','🌟 Primeira Marca','Primeiro check-in','🌟',20),
      _mkC('seq_3','🔥 3 em Sequência','Streak de 3 dias','🔥',30),
      _mkC('semana_completa','💪 Semana Completa','7 dias streak','💪',100),
      _mkC('dia_perfeito','💎 Dia Perfeito','Score 100%','💎',50),
      _mkC('seq_10','🚀 10 em Sequência','10 dias streak','🚀',200),
      _mkC('tarefa_critica','⚔️ Caçador','Tarefa crítica','⚔️',60),
      _mkC('tarefas_10','📋 Executor','10 tarefas','📋',80),
      _mkC('tarefas_50','🏆 Campeão','50 tarefas','🏆',250),
      _mkC('diario_3','📓 Diário Ativo','3 entradas diário','📓',30),
      _mkC('nivel_5','⭐ Proficiente','Nível 5','⭐',150),
      _mkC('nivel_max','👑 Grão-Mestre','Nível máximo','👑',500),
      _mkC('delegou','🤝 Líder','Delegou tarefa','🤝',20),
    ];
    for (final c in lista) await boxConquistas.add(c);
  }

  Conquista _mkC(String id, String titulo, String desc, String icone, int xp) =>
      Conquista()..id=id..titulo=titulo..descricao=desc..icone=icone
        ..desbloqueada=false..desbloquadaEm=null..xpBonus=xp;

  Future<void> _verificarConquistas() async {
    await inicializarConquistas();
    final p = perfil;

    Future<void> desbloquear(String id) async {
      try {
        final c = boxConquistas.values.firstWhere((c) => c.id == id);
        if (!c.desbloqueada) {
          c.desbloqueada = true;
          c.desbloquadaEm = DateTime.now();
          await c.save();
          p.xpTotal += c.xpBonus;
          if (!kIsWeb) {
            await NotificationService.instance.showImmediate(
              id: NotificationService.hashId('conquista_$id'),
              title: '🏅 Conquista Desbloqueada!',
              body: c.titulo,
              high: true,
            );
          }
        }
      } catch (_) {}
    }

    if (boxCheckins.isNotEmpty) await desbloquear('primeira_marca');
    if (p.streakAtual >= 3) await desbloquear('seq_3');
    if (p.streakAtual >= 7) await desbloquear('semana_completa');
    if (p.streakAtual >= 10) await desbloquear('seq_10');
    if (scoreDiaAtual >= 1.0) await desbloquear('dia_perfeito');
    if (p.totalTarefasConcluidas >= 10) await desbloquear('tarefas_10');
    if (p.totalTarefasConcluidas >= 50) await desbloquear('tarefas_50');
    if (boxDiario.length >= 3) await desbloquear('diario_3');
    if (p.nivel >= 5) await desbloquear('nivel_5');
    if (p.nivel >= 8) await desbloquear('nivel_max');
    if (boxTarefas.values.any((t) => t.concluida && t.tipo == 'critica'))
      await desbloquear('tarefa_critica');
    if (boxTarefas.values.any((t) => t.delegada)) await desbloquear('delegou');

    p.nivel = AppTheme.calcularNivel(p.xpTotal);
    _salvarPerfil(p);
  }

  // ─── Estatísticas ─────────────────────────────────────────
  Map<String, double> getScores30Dias() {
    final scores = <String, double>{};
    for (int i = 29; i >= 0; i--) {
      final d = DateTime.now().subtract(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(d);
      scores[key] = calcularScoreDia(key);
    }
    return scores;
  }

  double get mediaScore30Dias {
    final scores = getScores30Dias().values.where((v) => v > 0).toList();
    if (scores.isEmpty) return 0;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  int get diasComCheckin => boxCheckins.values.map((c) => c.data).toSet().length;
}
