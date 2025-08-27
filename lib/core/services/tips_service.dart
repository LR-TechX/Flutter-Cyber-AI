import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'notification_service.dart';

class TipsService {
  List<String> _tips = const [];
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString('assets/data/tips.json');
    final data = jsonDecode(raw) as List<dynamic>;
    _tips = data.whereType<String>().toList(growable: false);
    _loaded = true;
  }

  String get tipOfTheDay {
    if (_tips.isEmpty) return 'Stay safe online!';
    final dayIndex = DateTime.now().difference(DateTime(2024, 1, 1)).inDays;
    return _tips[dayIndex % _tips.length];
  }

  static Future<void> _alarmCallback() async {
    await NotificationService.show(title: 'CyberAI Tip', body: 'Open CyberAI for today\'s security tip.');
  }

  Future<void> scheduleDailyTip() async {
    await AndroidAlarmManager.initialize();
    final now = DateTime.now();
    final next9am = DateTime(now.year, now.month, now.day, 9).isBefore(now)
        ? DateTime(now.year, now.month, now.day + 1, 9)
        : DateTime(now.year, now.month, now.day, 9);
    final initialDelay = next9am.difference(now);
    await AndroidAlarmManager.periodic(
      const Duration(days: 1),
      9001,
      _alarmCallback,
      startAt: DateTime.now().add(initialDelay),
      wakeup: true,
      allowWhileIdle: true,
      exact: true,
    );
  }
}
