import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:network_info_plus/network_info_plus.dart';

class WifiScanResult {
  final String? ssid;
  final String? localIp;
  final List<String> reachable;
  final double progress; // 0..1
  const WifiScanResult({this.ssid, this.localIp, this.reachable = const [], this.progress = 0});

  WifiScanResult copyWith({String? ssid, String? localIp, List<String>? reachable, double? progress}) =>
      WifiScanResult(
        ssid: ssid ?? this.ssid,
        localIp: localIp ?? this.localIp,
        reachable: reachable ?? this.reachable,
        progress: progress ?? this.progress,
      );
}

class WifiScannerService {
  final NetworkInfo _info = NetworkInfo();

  Future<WifiScanResult> getInfo() async {
    final ssid = await _info.getWifiName();
    final ip = await _info.getWifiIP();
    return WifiScanResult(ssid: ssid, localIp: ip);
  }

  static Future<bool> _pingAddress(String ip) async {
    // Try TCP connect to port 80/443 with timeout as an ICMP substitute
    final ports = [80, 443];
    for (final port in ports) {
      try {
        final socket = await Socket.connect(ip, port, timeout: const Duration(milliseconds: 200));
        socket.destroy();
        return true;
      } catch (_) {
        // ignore
      }
    }
    return false;
  }

  static void _isolateEntry(SendPort sendPort) async {
    final port = ReceivePort();
    sendPort.send(port.sendPort);
    await for (final msg in port) {
      if (msg is List) {
        final SendPort replyTo = msg[0] as SendPort;
        final String ip = msg[1] as String;
        final ok = await _pingAddress(ip);
        replyTo.send([ip, ok]);
      }
    }
  }

  Future<Stream<WifiScanResult>> sweepSubnet() async {
    final info = await getInfo();
    final baseIp = info.localIp;
    if (baseIp == null || !baseIp.contains('.')) {
      return Stream.value(info);
    }
    final parts = baseIp.split('.');
    final subnet = '${parts[0]}.${parts[1]}.${parts[2]}';
    final controller = StreamController<WifiScanResult>();

    final reachable = <String>[];
    int completed = 0;
    const total = 254;

    // Spin up isolates
    const isolateCount = 8;
    final isolates = <SendPort>[];
    for (int i = 0; i < isolateCount; i++) {
      final rp = ReceivePort();
      await Isolate.spawn(_isolateEntry, rp.sendPort);
      final send = await rp.first as SendPort;
      isolates.add(send);
    }

    final replyPort = ReceivePort();
    replyPort.listen((msg) {
      final ip = msg[0] as String;
      final ok = msg[1] as bool;
      completed++;
      if (ok) reachable.add(ip);
      controller.add(info.copyWith(reachable: List.unmodifiable(reachable), progress: completed / total));
      if (completed >= total) {
        replyPort.close();
        controller.close();
      }
    });

    int nextIsolate = 0;
    for (int i = 1; i <= 254; i++) {
      final ip = '$subnet.$i';
      isolates[nextIsolate].send([replyPort.sendPort, ip]);
      nextIsolate = (nextIsolate + 1) % isolates.length;
    }

    // Emit initial state
    controller.add(info.copyWith(progress: 0));
    return controller.stream;
  }
}
