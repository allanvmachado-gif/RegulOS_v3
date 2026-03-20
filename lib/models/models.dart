// ═══════════════════════════════════════════════════════════
//  models.dart — RegulOS v3  (com Regulação + Diário melhorado)
// ═══════════════════════════════════════════════════════════
import 'package:hive/hive.dart';
part 'models.g.dart';

// ── TypeIds ──────────────────────────────────────────────
// 0=Tarefa 1=BlocoRotina 2=CheckIn 3=Reuniao 4=Compromisso
// 5=EntradaDiario 6=Conquista 7=Perfil
// 8=AvaliacaoMatinal 9=RegulacaoRegistro 10=AtividadeRecarga

// ═══════════════════════════════════════════════════════════
//  Tarefa
// ═══════════════════════════════════════════════════════════
@HiveType(typeId: 0)
class Tarefa extends HiveObject {
  @HiveField(0)  late String   id;
  @HiveField(1)  late String   titulo;
  @HiveField(2)  late String   descricao;
  @HiveField(3)  late String   tipo;         // critica|importante|urgente|comum
  @HiveField(4)  late String   dificuldade;  // dificil|medio|facil
  @HiveField(5)  late String   area;         // trabalho|pessoal|saude|...
  @HiveField(6)  late bool     concluida;
  @HiveField(7)  late bool     delegada;
  @HiveField(8)  late String   delegadoPara;
  @HiveField(9)  DateTime?     dataPrazo;
  @HiveField(10) late DateTime criadaEm;
  @HiveField(11) DateTime?     concluidaEm;
  @HiveField(12) late int      xpGanho;
  @HiveField(13) late bool     notificar;
  @HiveField(14) late String   periodo;      // manha|tarde|noite|anytime
  @HiveField(15) late int      custoRegulacao; // custo em pontos de regulação
}

// ═══════════════════════════════════════════════════════════
//  BlocoRotina
// ═══════════════════════════════════════════════════════════
@HiveType(typeId: 1)
class BlocoRotina extends HiveObject {
  @HiveField(0) late String    id;
  @HiveField(1) late String    titulo;
  @HiveField(2) late String    horarioInicio;
  @HiveField(3) late String    horarioFim;
  @HiveField(4) late String    icone;
  @HiveField(5) late String    cor;
  @HiveField(6) late List<int> diasSemana;
  @HiveField(7) late bool      ativo;
  @HiveField(8) late String    descricao;
  @HiveField(9) late bool      notificar;
}

// ═══════════════════════════════════════════════════════════
//  CheckIn
// ═══════════════════════════════════════════════════════════
@HiveType(typeId: 2)
class CheckIn extends HiveObject {
  @HiveField(0) late String   id;
  @HiveField(1) late String   blocoId;
  @HiveField(2) late String   data;
  @HiveField(3) late String   status;      // feito|parcial|pulado
  @HiveField(4) late DateTime registradoEm;
}

// ═══════════════════════════════════════════════════════════
//  Reuniao
// ═══════════════════════════════════════════════════════════
@HiveType(typeId: 3)
class Reuniao extends HiveObject {
  @HiveField(0) late String   id;
  @HiveField(1) late String   titulo;
  @HiveField(2) late DateTime dataHora;
  @HiveField(3) late int      duracaoMinutos;
  @HiveField(4) late String   local;
  @HiveField(5) late String   participantes;
  @HiveField(6) late String   notas;
  @HiveField(7) late bool     notificar;
  @HiveField(8) late String   cor;
  @HiveField(9) late String   periodo;     // manha|tarde|noite|anytime
}

// ═══════════════════════════════════════════════════════════
//  Compromisso
// ═══════════════════════════════════════════════════════════
@HiveType(typeId: 4)
class Compromisso extends HiveObject {
  @HiveField(0) late String   id;
  @HiveField(1) late String   titulo;
  @HiveField(2) late DateTime dataHora;
  @HiveField(3) late String   local;
  @HiveField(4) late String   notas;
  @HiveField(5) late bool     notificar;
  @HiveField(6) late String   tipo;
  @HiveField(7) late String   cor;
  @HiveField(8) late String   periodo;     // manha|tarde|noite|anytime
}

// ═══════════════════════════════════════════════════════════
//  EntradaDiario  (melhorada com post-it + objetivos)
// ═══════════════════════════════════════════════════════════
@HiveType(typeId: 5)
class EntradaDiario extends HiveObject {
  @HiveField(0)  late String  id;
  @HiveField(1)  late String  data;           // yyyy-MM-dd
  @HiveField(2)  late String  conteudo;       // anotação livre
  @HiveField(3)  late String  humor;          // otimo|bom|neutro|ruim|pessimo
  @HiveField(4)  late DateTime criadoEm;
  @HiveField(5)  late int     energiaNivel;   // 1–5
  @HiveField(6)  late String  objetivosManha; // objetivos do começo do dia
  @HiveField(7)  late String  resultadoNoite; // resultados ao final
  @HiveField(8)  late int     corPostIt;      // índice da cor (0-5)
  @HiveField(9)  late bool    memoriaPositiva; // true=boa, false=ruim
  @HiveField(10) late List<String> tags;      // tags livres
}

// ═══════════════════════════════════════════════════════════
//  Conquista
// ═══════════════════════════════════════════════════════════
@HiveType(typeId: 6)
class Conquista extends HiveObject {
  @HiveField(0) late String    id;
  @HiveField(1) late String    titulo;
  @HiveField(2) late String    descricao;
  @HiveField(3) late String    icone;
  @HiveField(4) late bool      desbloqueada;
  @HiveField(5) DateTime?      desbloquadaEm;
  @HiveField(6) late int       xpBonus;
}

// ═══════════════════════════════════════════════════════════
//  Perfil
// ═══════════════════════════════════════════════════════════
@HiveType(typeId: 7)
class Perfil extends HiveObject {
  @HiveField(0)  late String   nome;
  @HiveField(1)  late String   descricao;
  @HiveField(2)  late int      xpTotal;
  @HiveField(3)  late int      nivel;
  @HiveField(4)  late int      streakAtual;
  @HiveField(5)  late int      streakMaximo;
  @HiveField(6)  String?       fotoPath;
  @HiveField(7)  DateTime?     ultimoCheckin;
  @HiveField(8)  late int      totalTarefasConcluidas;
  @HiveField(9)  late int      totalBlocosFeitos;
}

// ═══════════════════════════════════════════════════════════
//  AvaliacaoMatinal  (nova)
// ═══════════════════════════════════════════════════════════
@HiveType(typeId: 8)
class AvaliacaoMatinal extends HiveObject {
  @HiveField(0) late String   id;
  @HiveField(1) late String   data;           // yyyy-MM-dd
  @HiveField(2) late int      qualidadeSono;  // 1–5
  @HiveField(3) late int      humor;          // 1–5
  @HiveField(4) late int      energiaFisica;  // 1–5
  @HiveField(5) late int      bateriaInicial; // calculado (0–100)
  @HiveField(6) late String   observacoes;
  @HiveField(7) late int      nivelStress;    // 1–5
  @HiveField(8) late int      bateriaRestante;// atualizado ao longo do dia
  @HiveField(9) late int      ganhoTotal;     // total de pontos ganhos no dia
  @HiveField(10) late int     custoTotal;     // total de pontos gastos no dia
  @HiveField(11) late bool    dorFisica;      // sente dor/desconforto
  @HiveField(12) late int      bateriaIniciada; // snapshot inicial
  @HiveField(13) late DateTime  timestamp;       // quando foi salva
}

// ═══════════════════════════════════════════════════════════
//  RegulacaoRegistro  (log de cada evento de regulação)
// ═══════════════════════════════════════════════════════════
@HiveType(typeId: 9)
class RegulacaoRegistro extends HiveObject {
  @HiveField(0) late String   id;
  @HiveField(1) late String   data;           // yyyy-MM-dd
  @HiveField(2) late String   tipo;           // custo|ganho
  @HiveField(3) late int      pontos;         // positivo=ganho, negativo=custo
  @HiveField(4) late String   descricao;      // "Tarefa crítica concluída"
  @HiveField(5) late DateTime registradoEm;
  @HiveField(6) late String   categoria;      // tarefa|reuniao|recarga|outro
}

// ═══════════════════════════════════════════════════════════
//  AtividadeRecarga  (atividades que recuperam regulação)
// ═══════════════════════════════════════════════════════════
@HiveType(typeId: 10)
class AtividadeRecarga extends HiveObject {
  @HiveField(0) late String  id;
  @HiveField(1) late String  nome;
  @HiveField(2) late String  icone;
  @HiveField(3) late int     pontosRecuperacao; // quantos pontos recupera
  @HiveField(4) late bool    ativa;
  @HiveField(5) late bool    personalizada;    // criada pelo usuário
}
