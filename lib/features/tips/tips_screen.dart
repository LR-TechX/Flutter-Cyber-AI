import 'package:flutter/material.dart';
import '../../core/services/tips_service.dart';
import '../../core/services/notification_service.dart';

class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  final _svc = TipsService();
  String _tip = 'Loading…';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _svc.load();
    await NotificationService.init();
    await _svc.scheduleDailyTip();
    setState(() => _tip = _svc.tipOfTheDay);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Tip of the Day', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(_tip, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
