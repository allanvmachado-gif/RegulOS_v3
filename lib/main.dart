// ═══════════════════════════════════════════════════════════
//  main.dart — RegulOS v3
// ═══════════════════════════════════════════════════════════
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'firebase_options.dart';
import 'models/models.dart';
import 'services/app_state.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'widgets/lock_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Locale pt_BR
  await initializeDateFormatting('pt_BR', null);

  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Hive (local storage)
  await Hive.initFlutter();
  Hive.registerAdapter(TarefaAdapter());
  Hive.registerAdapter(BlocoRotinaAdapter());
  Hive.registerAdapter(CheckInAdapter());
  Hive.registerAdapter(ReuniaoAdapter());
  Hive.registerAdapter(CompromissoAdapter());
  Hive.registerAdapter(EntradaDiarioAdapter());
  Hive.registerAdapter(ConquistaAdapter());
  Hive.registerAdapter(PerfilAdapter());
  Hive.registerAdapter(AvaliacaoMatinalAdapter());
  Hive.registerAdapter(RegulacaoRegistroAdapter());
  Hive.registerAdapter(AtividadeRecargaAdapter());

  await Hive.openBox<Tarefa>('tarefas');
  await Hive.openBox<BlocoRotina>('blocos');
  await Hive.openBox<CheckIn>('checkins');
  await Hive.openBox<Reuniao>('reunioes');
  await Hive.openBox<Compromisso>('compromissos');
  await Hive.openBox<EntradaDiario>('diario');
  await Hive.openBox<Conquista>('conquistas');
  await Hive.openBox<Perfil>('perfil');
  await Hive.openBox<AvaliacaoMatinal>('avaliacoes');
  await Hive.openBox<RegulacaoRegistro>('regulacao_log');
  await Hive.openBox<AtividadeRecarga>('recargas');
  await Hive.openBox('config');

  // Notificações (somente mobile)
  if (!kIsWeb) {
    tz.initializeTimeZones();
    await NotificationService.instance.initialize();
  }

  // Orientação (somente mobile)
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const RegulOSApp(),
    ),
  );
}

class RegulOSApp extends StatelessWidget {
  const RegulOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RegulOS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const AppRoot(),
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});
  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _unlocked = false;
  bool _checkingLock = true;

  @override
  void initState() {
    super.initState();
    _checkLock();
  }

  Future<void> _checkLock() async {
    if (kIsWeb) {
      setState(() { _unlocked = true; _checkingLock = false; });
      return;
    }
    final box = Hive.box('config');
    final lockType = box.get('lockType', defaultValue: 'none') as String;
    setState(() {
      _unlocked = lockType == 'none';
      _checkingLock = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingLock) {
      return const Scaffold(
        backgroundColor: AppTheme.bg,
        body: Center(child: CircularProgressIndicator(
          color: AppTheme.accent)),
      );
    }
    if (!_unlocked) {
      return LockScreen(onUnlocked: () => setState(() => _unlocked = true));
    }
    return const AuthGate();
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.read<AppState>().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppTheme.bg,
            body: Center(child: CircularProgressIndicator(
              color: AppTheme.accent)),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginScreen();
        }
        return const HomeScreen();
      },
    );
  }
}
