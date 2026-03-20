// GENERATED CODE - DO NOT MODIFY BY HAND
// ═══════════════════════════════════════════════════════════
//  models.g.dart — Hive Adapters (gerado manualmente para RegulOS v3)
// ═══════════════════════════════════════════════════════════

part of 'models.dart';

// ──────────────────────────────────────────
//  TarefaAdapter  (typeId: 0)
// ──────────────────────────────────────────
class TarefaAdapter extends TypeAdapter<Tarefa> {
  @override final int typeId = 0;
  @override
  Tarefa read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (var i = 0; i < n; i++) reader.readByte(): reader.read()};
    return Tarefa()
      ..id             = (f[0]  as String)
      ..titulo         = (f[1]  as String)
      ..descricao      = (f[2]  as String)
      ..tipo           = (f[3]  as String)
      ..dificuldade    = (f[4]  as String)
      ..area           = (f[5]  as String)
      ..concluida      = (f[6]  as bool)
      ..delegada       = (f[7]  as bool)
      ..delegadoPara   = (f[8]  as String)
      ..dataPrazo      = (f[9]  as DateTime?)
      ..criadaEm       = (f[10] as DateTime)
      ..concluidaEm    = (f[11] as DateTime?)
      ..xpGanho        = (f[12] as int)
      ..notificar      = (f[13] as bool)
      ..periodo        = (f[14] as String? ?? 'anytime')
      ..custoRegulacao = (f[15] as int? ?? 3);
  }
  @override
  void write(BinaryWriter writer, Tarefa obj) {
    writer.writeByte(16);
    writer..writeByte(0)..write(obj.id)
          ..writeByte(1)..write(obj.titulo)
          ..writeByte(2)..write(obj.descricao)
          ..writeByte(3)..write(obj.tipo)
          ..writeByte(4)..write(obj.dificuldade)
          ..writeByte(5)..write(obj.area)
          ..writeByte(6)..write(obj.concluida)
          ..writeByte(7)..write(obj.delegada)
          ..writeByte(8)..write(obj.delegadoPara)
          ..writeByte(9)..write(obj.dataPrazo)
          ..writeByte(10)..write(obj.criadaEm)
          ..writeByte(11)..write(obj.concluidaEm)
          ..writeByte(12)..write(obj.xpGanho)
          ..writeByte(13)..write(obj.notificar)
          ..writeByte(14)..write(obj.periodo)
          ..writeByte(15)..write(obj.custoRegulacao);
  }
  @override bool operator ==(Object o) => o is TarefaAdapter;
  @override int get hashCode => typeId.hashCode;
}

// ──────────────────────────────────────────
//  BlocoRotinaAdapter  (typeId: 1)
// ──────────────────────────────────────────
class BlocoRotinaAdapter extends TypeAdapter<BlocoRotina> {
  @override final int typeId = 1;
  @override
  BlocoRotina read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (var i = 0; i < n; i++) reader.readByte(): reader.read()};
    return BlocoRotina()
      ..id           = (f[0] as String)
      ..titulo       = (f[1] as String)
      ..horarioInicio= (f[2] as String)
      ..horarioFim   = (f[3] as String)
      ..icone        = (f[4] as String)
      ..cor          = (f[5] as String)
      ..diasSemana   = (f[6] as List).cast<int>()
      ..ativo        = (f[7] as bool)
      ..descricao    = (f[8] as String)
      ..notificar    = (f[9] as bool);
  }
  @override
  void write(BinaryWriter writer, BlocoRotina obj) {
    writer.writeByte(10);
    writer..writeByte(0)..write(obj.id)
          ..writeByte(1)..write(obj.titulo)
          ..writeByte(2)..write(obj.horarioInicio)
          ..writeByte(3)..write(obj.horarioFim)
          ..writeByte(4)..write(obj.icone)
          ..writeByte(5)..write(obj.cor)
          ..writeByte(6)..write(obj.diasSemana)
          ..writeByte(7)..write(obj.ativo)
          ..writeByte(8)..write(obj.descricao)
          ..writeByte(9)..write(obj.notificar);
  }
  @override bool operator ==(Object o) => o is BlocoRotinaAdapter;
  @override int get hashCode => typeId.hashCode;
}

// ──────────────────────────────────────────
//  CheckInAdapter  (typeId: 2)
// ──────────────────────────────────────────
class CheckInAdapter extends TypeAdapter<CheckIn> {
  @override final int typeId = 2;
  @override
  CheckIn read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (var i = 0; i < n; i++) reader.readByte(): reader.read()};
    return CheckIn()
      ..id          = (f[0] as String)
      ..blocoId     = (f[1] as String)
      ..data        = (f[2] as String)
      ..status      = (f[3] as String)
      ..registradoEm= (f[4] as DateTime);
  }
  @override
  void write(BinaryWriter writer, CheckIn obj) {
    writer.writeByte(5);
    writer..writeByte(0)..write(obj.id)
          ..writeByte(1)..write(obj.blocoId)
          ..writeByte(2)..write(obj.data)
          ..writeByte(3)..write(obj.status)
          ..writeByte(4)..write(obj.registradoEm);
  }
  @override bool operator ==(Object o) => o is CheckInAdapter;
  @override int get hashCode => typeId.hashCode;
}

// ──────────────────────────────────────────
//  ReuniaoAdapter  (typeId: 3)
// ──────────────────────────────────────────
class ReuniaoAdapter extends TypeAdapter<Reuniao> {
  @override final int typeId = 3;
  @override
  Reuniao read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (var i = 0; i < n; i++) reader.readByte(): reader.read()};
    return Reuniao()
      ..id             = (f[0] as String)
      ..titulo         = (f[1] as String)
      ..dataHora       = (f[2] as DateTime)
      ..duracaoMinutos = (f[3] as int)
      ..local          = (f[4] as String)
      ..participantes  = (f[5] as String)
      ..notas          = (f[6] as String)
      ..notificar      = (f[7] as bool)
      ..cor            = (f[8] as String)
      ..periodo        = (f[9] as String? ?? 'anytime');
  }
  @override
  void write(BinaryWriter writer, Reuniao obj) {
    writer.writeByte(10);
    writer..writeByte(0)..write(obj.id)
          ..writeByte(1)..write(obj.titulo)
          ..writeByte(2)..write(obj.dataHora)
          ..writeByte(3)..write(obj.duracaoMinutos)
          ..writeByte(4)..write(obj.local)
          ..writeByte(5)..write(obj.participantes)
          ..writeByte(6)..write(obj.notas)
          ..writeByte(7)..write(obj.notificar)
          ..writeByte(8)..write(obj.cor)
          ..writeByte(9)..write(obj.periodo);
  }
  @override bool operator ==(Object o) => o is ReuniaoAdapter;
  @override int get hashCode => typeId.hashCode;
}

// ──────────────────────────────────────────
//  CompromissoAdapter  (typeId: 4)
// ──────────────────────────────────────────
class CompromissoAdapter extends TypeAdapter<Compromisso> {
  @override final int typeId = 4;
  @override
  Compromisso read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (var i = 0; i < n; i++) reader.readByte(): reader.read()};
    return Compromisso()
      ..id       = (f[0] as String)
      ..titulo   = (f[1] as String)
      ..dataHora = (f[2] as DateTime)
      ..local    = (f[3] as String)
      ..notas    = (f[4] as String)
      ..notificar= (f[5] as bool)
      ..tipo     = (f[6] as String)
      ..cor      = (f[7] as String)
      ..periodo  = (f[8] as String? ?? 'anytime');
  }
  @override
  void write(BinaryWriter writer, Compromisso obj) {
    writer.writeByte(9);
    writer..writeByte(0)..write(obj.id)
          ..writeByte(1)..write(obj.titulo)
          ..writeByte(2)..write(obj.dataHora)
          ..writeByte(3)..write(obj.local)
          ..writeByte(4)..write(obj.notas)
          ..writeByte(5)..write(obj.notificar)
          ..writeByte(6)..write(obj.tipo)
          ..writeByte(7)..write(obj.cor)
          ..writeByte(8)..write(obj.periodo);
  }
  @override bool operator ==(Object o) => o is CompromissoAdapter;
  @override int get hashCode => typeId.hashCode;
}

// ──────────────────────────────────────────
//  EntradaDiarioAdapter  (typeId: 5)
// ──────────────────────────────────────────
class EntradaDiarioAdapter extends TypeAdapter<EntradaDiario> {
  @override final int typeId = 5;
  @override
  EntradaDiario read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (var i = 0; i < n; i++) reader.readByte(): reader.read()};
    return EntradaDiario()
      ..id              = (f[0]  as String)
      ..data            = (f[1]  as String)
      ..conteudo        = (f[2]  as String)
      ..humor           = (f[3]  as String)
      ..criadoEm        = (f[4]  as DateTime)
      ..energiaNivel    = (f[5]  as int)
      ..objetivosManha  = (f[6]  as String? ?? '')
      ..resultadoNoite  = (f[7]  as String? ?? '')
      ..corPostIt       = (f[8]  as int? ?? 0)
      ..memoriaPositiva = (f[9]  as bool? ?? true)
      ..tags            = (f[10] as List? ?? []).cast<String>();
  }
  @override
  void write(BinaryWriter writer, EntradaDiario obj) {
    writer.writeByte(11);
    writer..writeByte(0)..write(obj.id)
          ..writeByte(1)..write(obj.data)
          ..writeByte(2)..write(obj.conteudo)
          ..writeByte(3)..write(obj.humor)
          ..writeByte(4)..write(obj.criadoEm)
          ..writeByte(5)..write(obj.energiaNivel)
          ..writeByte(6)..write(obj.objetivosManha)
          ..writeByte(7)..write(obj.resultadoNoite)
          ..writeByte(8)..write(obj.corPostIt)
          ..writeByte(9)..write(obj.memoriaPositiva)
          ..writeByte(10)..write(obj.tags);
  }
  @override bool operator ==(Object o) => o is EntradaDiarioAdapter;
  @override int get hashCode => typeId.hashCode;
}

// ──────────────────────────────────────────
//  ConquistaAdapter  (typeId: 6)
// ──────────────────────────────────────────
class ConquistaAdapter extends TypeAdapter<Conquista> {
  @override final int typeId = 6;
  @override
  Conquista read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (var i = 0; i < n; i++) reader.readByte(): reader.read()};
    return Conquista()
      ..id            = (f[0] as String)
      ..titulo        = (f[1] as String)
      ..descricao     = (f[2] as String)
      ..icone         = (f[3] as String)
      ..desbloqueada  = (f[4] as bool)
      ..desbloquadaEm = (f[5] as DateTime?)
      ..xpBonus       = (f[6] as int);
  }
  @override
  void write(BinaryWriter writer, Conquista obj) {
    writer.writeByte(7);
    writer..writeByte(0)..write(obj.id)
          ..writeByte(1)..write(obj.titulo)
          ..writeByte(2)..write(obj.descricao)
          ..writeByte(3)..write(obj.icone)
          ..writeByte(4)..write(obj.desbloqueada)
          ..writeByte(5)..write(obj.desbloquadaEm)
          ..writeByte(6)..write(obj.xpBonus);
  }
  @override bool operator ==(Object o) => o is ConquistaAdapter;
  @override int get hashCode => typeId.hashCode;
}

// ──────────────────────────────────────────
//  PerfilAdapter  (typeId: 7)
// ──────────────────────────────────────────
class PerfilAdapter extends TypeAdapter<Perfil> {
  @override final int typeId = 7;
  @override
  Perfil read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (var i = 0; i < n; i++) reader.readByte(): reader.read()};
    return Perfil()
      ..nome                   = (f[0] as String)
      ..descricao              = (f[1] as String)
      ..xpTotal                = (f[2] as int)
      ..nivel                  = (f[3] as int)
      ..streakAtual            = (f[4] as int)
      ..streakMaximo           = (f[5] as int)
      ..fotoPath               = (f[6] as String?)
      ..ultimoCheckin          = (f[7] as DateTime?)
      ..totalTarefasConcluidas = (f[8] as int)
      ..totalBlocosFeitos      = (f[9] as int);
  }
  @override
  void write(BinaryWriter writer, Perfil obj) {
    writer.writeByte(10);
    writer..writeByte(0)..write(obj.nome)
          ..writeByte(1)..write(obj.descricao)
          ..writeByte(2)..write(obj.xpTotal)
          ..writeByte(3)..write(obj.nivel)
          ..writeByte(4)..write(obj.streakAtual)
          ..writeByte(5)..write(obj.streakMaximo)
          ..writeByte(6)..write(obj.fotoPath)
          ..writeByte(7)..write(obj.ultimoCheckin)
          ..writeByte(8)..write(obj.totalTarefasConcluidas)
          ..writeByte(9)..write(obj.totalBlocosFeitos);
  }
  @override bool operator ==(Object o) => o is PerfilAdapter;
  @override int get hashCode => typeId.hashCode;
}

// ──────────────────────────────────────────
//  AvaliacaoMatinalAdapter  (typeId: 8)
// ──────────────────────────────────────────
class AvaliacaoMatinalAdapter extends TypeAdapter<AvaliacaoMatinal> {
  @override final int typeId = 8;
  @override
  AvaliacaoMatinal read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (var i = 0; i < n; i++) reader.readByte(): reader.read()};
    return AvaliacaoMatinal()
      ..id              = (f[0]  as String)
      ..data            = (f[1]  as String)
      ..qualidadeSono   = (f[2]  as int)
      ..humor           = (f[3]  as int)
      ..energiaFisica   = (f[4]  as int)
      ..bateriaInicial  = (f[5]  as int)
      ..observacoes     = (f[6]  as String)
      ..nivelStress     = (f[7]  as int)
      ..bateriaRestante = (f[8]  as int)
      ..ganhoTotal      = (f[9]  as int? ?? 0)
      ..custoTotal      = (f[10] as int? ?? 0)
      ..dorFisica       = (f[11] as bool? ?? false)
      ..bateriaIniciada = (f[12] as int? ?? 100)
      ..timestamp       = (f[13] as DateTime? ?? DateTime.now());
  }
  @override
  void write(BinaryWriter writer, AvaliacaoMatinal obj) {
    writer.writeByte(14);
    writer..writeByte(0)..write(obj.id)
          ..writeByte(1)..write(obj.data)
          ..writeByte(2)..write(obj.qualidadeSono)
          ..writeByte(3)..write(obj.humor)
          ..writeByte(4)..write(obj.energiaFisica)
          ..writeByte(5)..write(obj.bateriaInicial)
          ..writeByte(6)..write(obj.observacoes)
          ..writeByte(7)..write(obj.nivelStress)
          ..writeByte(8)..write(obj.bateriaRestante)
          ..writeByte(9)..write(obj.ganhoTotal)
          ..writeByte(10)..write(obj.custoTotal)
          ..writeByte(11)..write(obj.dorFisica)
          ..writeByte(12)..write(obj.bateriaIniciada)
          ..writeByte(13)..write(obj.timestamp);
  }
  @override bool operator ==(Object o) => o is AvaliacaoMatinalAdapter;
  @override int get hashCode => typeId.hashCode;
}

// ──────────────────────────────────────────
//  RegulacaoRegistroAdapter  (typeId: 9)
// ──────────────────────────────────────────
class RegulacaoRegistroAdapter extends TypeAdapter<RegulacaoRegistro> {
  @override final int typeId = 9;
  @override
  RegulacaoRegistro read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (var i = 0; i < n; i++) reader.readByte(): reader.read()};
    return RegulacaoRegistro()
      ..id           = (f[0] as String)
      ..data         = (f[1] as String)
      ..tipo         = (f[2] as String)
      ..pontos       = (f[3] as int)
      ..descricao    = (f[4] as String)
      ..registradoEm = (f[5] as DateTime)
      ..categoria    = (f[6] as String);
  }
  @override
  void write(BinaryWriter writer, RegulacaoRegistro obj) {
    writer.writeByte(7);
    writer..writeByte(0)..write(obj.id)
          ..writeByte(1)..write(obj.data)
          ..writeByte(2)..write(obj.tipo)
          ..writeByte(3)..write(obj.pontos)
          ..writeByte(4)..write(obj.descricao)
          ..writeByte(5)..write(obj.registradoEm)
          ..writeByte(6)..write(obj.categoria);
  }
  @override bool operator ==(Object o) => o is RegulacaoRegistroAdapter;
  @override int get hashCode => typeId.hashCode;
}

// ──────────────────────────────────────────
//  AtividadeRecargaAdapter  (typeId: 10)
// ──────────────────────────────────────────
class AtividadeRecargaAdapter extends TypeAdapter<AtividadeRecarga> {
  @override final int typeId = 10;
  @override
  AtividadeRecarga read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (var i = 0; i < n; i++) reader.readByte(): reader.read()};
    return AtividadeRecarga()
      ..id                  = (f[0] as String)
      ..nome                = (f[1] as String)
      ..icone               = (f[2] as String)
      ..pontosRecuperacao   = (f[3] as int)
      ..ativa               = (f[4] as bool)
      ..personalizada       = (f[5] as bool);
  }
  @override
  void write(BinaryWriter writer, AtividadeRecarga obj) {
    writer.writeByte(6);
    writer..writeByte(0)..write(obj.id)
          ..writeByte(1)..write(obj.nome)
          ..writeByte(2)..write(obj.icone)
          ..writeByte(3)..write(obj.pontosRecuperacao)
          ..writeByte(4)..write(obj.ativa)
          ..writeByte(5)..write(obj.personalizada);
  }
  @override bool operator ==(Object o) => o is AtividadeRecargaAdapter;
  @override int get hashCode => typeId.hashCode;
}
