// ═══════════════════════════════════════════════════════════
//  home_screen.dart — RegulOS navegação principal
// ═══════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/level_up_overlay.dart';
import 'meu_dia_screen.dart';
import 'tarefas_screen.dart';
import 'reunioes_screen.dart';
import 'compromissos_screen.dart';
import 'diario_screen.dart';
import 'stats_screen.dart';
import 'perfil_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int? _levelUpNivel;
  int _lastNivel = 0;
  bool _syncing = false;

  final List<Widget> _screens = const [
    MeuDiaScreen(),
    TarefasScreen(),
    ReunioesScreen(),
    CompromissosScreen(),
    DiarioScreen(),
    StatsScreen(),
    PerfilScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<AppState>();
      state.inicializarConquistas();
      _lastNivel = state.perfil.nivel;
    });
  }

  void _checkLevelUp(AppState state) {
    final novoNivel = state.perfil.nivel;
    if (novoNivel > _lastNivel && _lastNivel > 0) {
      setState(() => _levelUpNivel = novoNivel);
    }
    _lastNivel = novoNivel;
  }

  Future<void> _sync() async {
    setState(() => _syncing = true);
    await context.read<AppState>().sincronizarAgora();
    if (mounted) {
      setState(() => _syncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(children: [
            Icon(Icons.cloud_done_rounded, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text('Dados sincronizados!'),
          ]),
          backgroundColor: AppTheme.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _checkLevelUp(state));

        return Stack(
          children: [
            Scaffold(
              backgroundColor: AppTheme.bg,
              body: IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),
              bottomNavigationBar: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Barra de sync/user ──────────────────
                  Container(
                    color: AppTheme.surface,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        if (state.currentUser != null) ...[
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: AppTheme.accent.withOpacity(0.2),
                            child: Text(
                              (state.currentUser!.displayName ?? 'R')[0].toUpperCase(),
                              style: const TextStyle(color: AppTheme.accentLight, fontSize: 10),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              state.currentUser!.displayName ?? '',
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ] else
                          const Spacer(),
                        // Sync
                        IconButton(
                          icon: _syncing
                              ? const SizedBox(
                                  width: 16, height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: AppTheme.accentLight))
                              : const Icon(Icons.sync_rounded,
                                  color: AppTheme.accentLight, size: 18),
                          onPressed: _syncing ? null : _sync,
                          tooltip: 'Sincronizar',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                        // Logout
                        IconButton(
                          icon: const Icon(Icons.logout_rounded,
                              color: AppTheme.textMuted, size: 16),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                backgroundColor: AppTheme.surface,
                                title: const Text('Sair',
                                    style: TextStyle(color: AppTheme.text)),
                                content: const Text(
                                    'Os dados serão sincronizados antes de sair.',
                                    style: TextStyle(color: AppTheme.textMuted)),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Sair',
                                        style: TextStyle(color: AppTheme.red)),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true && context.mounted) {
                              await context.read<AppState>().signOut();
                            }
                          },
                          tooltip: 'Sair',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                      ],
                    ),
                  ),
                  // ── Nav Bar ─────────────────────────────
                  Container(
                    decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: AppTheme.divider))),
                    child: BottomNavigationBar(
                      currentIndex: _currentIndex,
                      onTap: (i) => setState(() => _currentIndex = i),
                      items: const [
                        BottomNavigationBarItem(
                            icon: Icon(Icons.today_rounded), label: 'Meu Dia'),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.task_alt_rounded), label: 'Tarefas'),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.groups_rounded), label: 'Reuniões'),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.event_rounded), label: 'Compromissos'),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.auto_stories_rounded), label: 'Diário'),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.bar_chart_rounded), label: 'Stats'),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.person_rounded), label: 'Perfil'),
                      ],
                      selectedFontSize: 10,
                      unselectedFontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            if (_levelUpNivel != null)
              Positioned.fill(
                child: LevelUpOverlay(
                  novoNivel: _levelUpNivel!,
                  onClose: () => setState(() => _levelUpNivel = null),
                ),
              ),
          ],
        );
      },
    );
  }
}
