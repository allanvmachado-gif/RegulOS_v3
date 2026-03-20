// ═══════════════════════════════════════════════════════════
//  notification_service.dart
// ═══════════════════════════════════════════════════════════
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings,
        onDidReceiveNotificationResponse: _onNotificationTap);

    // Solicitar permissões Android 13+
    final android =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();

    _initialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notificação tocada: ${response.payload}');
  }

  // Canal de alta prioridade
  static const AndroidNotificationDetails _androidHigh =
      AndroidNotificationDetails(
    'agenda_high',
    'Agenda — Alta Prioridade',
    channelDescription: 'Notificações de blocos e tarefas urgentes',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
    enableVibration: true,
    playSound: true,
  );

  static const AndroidNotificationDetails _androidDefault =
      AndroidNotificationDetails(
    'agenda_default',
    'Agenda — Geral',
    channelDescription: 'Lembretes gerais',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    icon: '@mipmap/ic_launcher',
  );

  // Notificação imediata
  Future<void> showImmediate({
    required int id,
    required String title,
    required String body,
    String? payload,
    bool high = false,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: high ? _androidHigh : _androidDefault,
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  // Notificação agendada
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    bool high = false,
  }) async {
    try {
      final localTz = tz.local;
      final scheduledTz = tz.TZDateTime.from(scheduledDate, localTz);

      if (scheduledTz.isBefore(tz.TZDateTime.now(localTz))) return;

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTz,
        NotificationDetails(
          android: high ? _androidHigh : _androidDefault,
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Erro ao agendar notificação: $e');
    }
  }

  // Notificação diária recorrente (ex: lembrete de rotina)
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        NotificationDetails(
          android: _androidDefault,
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Erro ao agendar notificação diária: $e');
    }
  }

  // Cancelar por ID
  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  // Cancelar todos
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // Gerar ID numérico a partir de string
  static int hashId(String id) => id.hashCode.abs() % 100000;
}
