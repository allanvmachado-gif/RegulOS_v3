// ═══════════════════════════════════════════════════════════
//  app_theme.dart — RegulOS Light Palette
// ═══════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Paleta RegulOS (inspirada no ícone claro) ──────────
  static const Color bg          = Color(0xFFF8F7F4); // creme quente
  static const Color surface     = Color(0xFFFFFFFF); // branco
  static const Color card        = Color(0xFFF0EEE9); // card suave
  static const Color accent      = Color(0xFF6B8DD6); // azul autismo
  static const Color accentLight = Color(0xFF8FA8E8); // azul claro
  static const Color accentDark  = Color(0xFF4A6BB5); // azul escuro
  static const Color gold        = Color(0xFFF5C518); // amarelo girassol TDAH
  static const Color green       = Color(0xFF7DC8A0); // verde sálvia
  static const Color orange      = Color(0xFFF5A878); // coral suave
  static const Color red         = Color(0xFFE88080); // vermelho suave
  static const Color blue        = Color(0xFF6B8DD6); // azul principal
  static const Color purple      = Color(0xFF9B8EC4); // roxo suave
  static const Color text        = Color(0xFF2D2D3A); // texto escuro
  static const Color textMuted   = Color(0xFF8A8A9A); // texto suave
  static const Color divider     = Color(0xFFE8E6E0); // divisor
  static const Color shadow      = Color(0x0F000000); // sombra leve

  // ── Regulação (bateria) ────────────────────────────────
  static const Color regulHigh   = Color(0xFF7DC8A0); // > 60 → verde
  static const Color regulMid    = Color(0xFFF5C518); // 40–60 → amarelo
  static const Color regulLow    = Color(0xFFE88080); // < 40 → vermelho

  // ── Períodos do dia ────────────────────────────────────
  static const Color manhaColor  = Color(0xFFFFF3CD); // amarelo claro
  static const Color tardeColor  = Color(0xFFD4EDFF); // azul claro
  static const Color noiteColor  = Color(0xFFE8D5F5); // roxo claro
  static const Color anytimeColor= Color(0xFFE8F5E9); // verde claro

  // ── Post-its do diário ────────────────────────────────
  static const List<Color> postItColors = [
    Color(0xFFFFF9C4), // amarelo
    Color(0xFFC8E6C9), // verde
    Color(0xFFFFCDD2), // rosa/vermelho
    Color(0xFFBBDEFB), // azul
    Color(0xFFE1BEE7), // roxo
    Color(0xFFFFE0B2), // laranja
  ];

  // ── ThemeData ──────────────────────────────────────────
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.light(
        primary: accent,
        secondary: gold,
        surface: surface,
        onPrimary: Colors.white,
        onSurface: text,
        error: red,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge:  TextStyle(color: text, fontWeight: FontWeight.bold),
          headlineLarge: TextStyle(color: text, fontWeight: FontWeight.bold),
          headlineMedium:TextStyle(color: text, fontWeight: FontWeight.w600),
          bodyLarge:     TextStyle(color: text),
          bodyMedium:    TextStyle(color: textMuted),
          labelLarge:    TextStyle(color: text, fontWeight: FontWeight.w600),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: text,
        elevation: 0,
        centerTitle: false,
        shadowColor: shadow,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: text, fontSize: 18, fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shadowColor: shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: divider, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: accent,
        unselectedItemColor: textMuted,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        shape: CircleBorder(),
        elevation: 2,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        labelStyle: const TextStyle(color: textMuted),
        hintStyle: const TextStyle(color: textMuted),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: card,
        labelStyle: const TextStyle(color: text, fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: const BorderSide(color: divider),
      ),
      dividerTheme: const DividerThemeData(color: divider, thickness: 1),
      dialogTheme: DialogTheme(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
            color: text, fontSize: 18, fontWeight: FontWeight.bold),
        contentTextStyle: const TextStyle(color: textMuted, fontSize: 14),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: text,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── XP por tipo/dificuldade ────────────────────────────
  static int calcularXP(String tipo, String dificuldade) {
    const tipoXP = {'critica': 300, 'importante': 60, 'urgente': 40, 'comum': 15};
    const difMult = {'dificil': 2.0, 'medio': 1.0, 'facil': 0.5};
    final base = tipoXP[tipo] ?? 15;
    final mult = difMult[dificuldade] ?? 1.0;
    return (base * mult).round().clamp(5, 300);
  }

  // XP reduzido para tarefas em atraso (70% do normal)
  static int calcularXPAtraso(String tipo, String dificuldade) {
    return (calcularXP(tipo, dificuldade) * 0.7).round();
  }

  // ── Custo de regulação por tipo de tarefa ─────────────
  static int custoRegulacao(String tipo) {
    const custo = {'critica': 15, 'importante': 8, 'urgente': 10, 'comum': 3};
    return custo[tipo] ?? 3;
  }

  // ── Custo de regulação por reunião ────────────────────
  static int custoRegulacaoReuniao(int duracaoMinutos) {
    return ((duracaoMinutos / 60) * 10).round().clamp(5, 25);
  }

  // ── Nível RPG ──────────────────────────────────────────
  static int calcularNivel(int xp) {
    if (xp < 100)   return 1;
    if (xp < 300)   return 2;
    if (xp < 700)   return 3;
    if (xp < 1500)  return 4;
    if (xp < 3000)  return 5;
    if (xp < 6000)  return 6;
    if (xp < 12000) return 7;
    return 8;
  }

  static String nomaNivel(int nivel) {
    const nomes = {
      1: 'Iniciante', 2: 'Aprendiz', 3: 'Praticante',
      4: 'Habilidoso', 5: 'Proficiente', 6: 'Experiente',
      7: 'Mestre', 8: 'Grão-Mestre',
    };
    return nomes[nivel] ?? 'Iniciante';
  }

  static int xpParaProximoNivel(int nivel) {
    const limites = {1:100, 2:300, 3:700, 4:1500, 5:3000, 6:6000, 7:12000, 8:99999};
    return limites[nivel] ?? 99999;
  }

  // ── Cor da bateria de regulação ───────────────────────
  static Color corBateria(int valor) {
    if (valor >= 60) return regulHigh;
    if (valor >= 40) return regulMid;
    return regulLow;
  }

  // ── Emoji da bateria ──────────────────────────────────
  static String emojiBateria(int valor) {
    if (valor >= 80) return '🔋';
    if (valor >= 60) return '🔋';
    if (valor >= 40) return '🪫';
    return '⚠️';
  }

  // ── Período do dia ────────────────────────────────────
  static String periodoAtual() {
    final h = TimeOfDay.now().hour;
    if (h >= 5  && h < 12) return 'manha';
    if (h >= 12 && h < 18) return 'tarde';
    if (h >= 18 && h < 22) return 'noite';
    return 'anytime';
  }

  static Color corPeriodo(String periodo) {
    switch (periodo) {
      case 'manha':   return manhaColor;
      case 'tarde':   return tardeColor;
      case 'noite':   return noiteColor;
      default:        return anytimeColor;
    }
  }

  static String labelPeriodo(String periodo) {
    switch (periodo) {
      case 'manha':   return '🌅 Manhã';
      case 'tarde':   return '☀️ Tarde';
      case 'noite':   return '🌙 Noite';
      default:        return '🕐 A qualquer hora';
    }
  }

  // ── Cor por tipo de tarefa ────────────────────────────
  static Color corTipo(String tipo) {
    switch (tipo) {
      case 'critica':    return red;
      case 'importante': return orange;
      case 'urgente':    return gold;
      default:           return blue;
    }
  }

  // ── Ícone por tipo de tarefa ──────────────────────────
  static IconData iconeTipo(String tipo) {
    switch (tipo) {
      case 'critica':    return Icons.priority_high_rounded;
      case 'importante': return Icons.star_rounded;
      case 'urgente':    return Icons.flash_on_rounded;
      default:           return Icons.radio_button_unchecked_rounded;
    }
  }

  // ── Cor por nível XP ──────────────────────────────────
  static Color xpLevelColor(int nivel) {
    if (nivel >= 8) return const Color(0xFFFFD700); // dourado
    if (nivel >= 6) return purple;
    if (nivel >= 4) return accent;
    if (nivel >= 2) return green;
    return textMuted;
  }

  // ── Título do nível (alias para nomaNivel) ────────────
  static String nivelTitulo(int nivel) => nomaNivel(nivel);
}
