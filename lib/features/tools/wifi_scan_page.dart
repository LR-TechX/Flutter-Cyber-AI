import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/services/wifi_scanner_service.dart';
import '../../core/services/notification_service.dart';

final wifiScanProvider = StateNotifierProvider<WifiScanController, WifiScanResult>((ref) => WifiScanController());

class WifiScanController extends StateNotifier<WifiScanResult> {
  WifiScanController() : super(const WifiScanResult());
  StreamSubscription? _sub;

  Future<void> start() async {
    final status = await Permission.location.request();
    if (!status.isGranted) {
      return;
    }
    final svc = WifiScannerService();
    final info = await svc.getInfo();
    state = info.copyWith(progress: 0);
    _sub?.cancel();
    final stream = await svc.sweepSubnet();
    _sub = stream.listen((r) async {
      state = r;
      if (r.progress >= 1.0) {
        await NotificationService.show(title: 'Wi‑Fi Scan Complete', body: '${r.reachable.length} hosts reachable');
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

class WifiScanPage extends ConsumerWidget {
  const WifiScanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(wifiScanProvider);
    return RefreshIndicator(
      onRefresh: () async => ref.read(wifiScanProvider.notifier).start(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            const Icon(Icons.wifi),
            const SizedBox(width: 8),
            Expanded(child: Text(result.ssid ?? 'SSID: unknown')),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.router_outlined),
            const SizedBox(width: 8),
            Expanded(child: Text('Local IP: ${result.localIp ?? 'unknown'}')),
          ]),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: result.progress == 0 ? null : result.progress),
          const SizedBox(height: 12),
          ElevatedButton.icon(onPressed: () => ref.read(wifiScanProvider.notifier).start(), icon: const Icon(Icons.play_arrow), label: const Text('Start Scan')),
          const SizedBox(height: 16),
          Text('Reachable Hosts (${result.reachable.length})', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...result.reachable.map((ip) => ListTile(leading: const Icon(Icons.check_circle, color: Colors.lightGreen), title: Text(ip))).toList(),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}
