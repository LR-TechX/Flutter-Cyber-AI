import 'package:flutter/material.dart';
import '../../core/services/phishing_service.dart';

class PhishingCheckerPage extends StatefulWidget {
  const PhishingCheckerPage({super.key});

  @override
  State<PhishingCheckerPage> createState() => _PhishingCheckerPageState();
}

class _PhishingCheckerPageState extends State<PhishingCheckerPage> {
  final TextEditingController _controller = TextEditingController();
  PhishingResult? _result;
  final _svc = PhishingService();

  void _check() {
    setState(() => _result = _svc.check(_controller.text));
  }

  @override
  Widget build(BuildContext context) {
    final risky = _result?.risky ?? false;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: 'Enter a URL to check'),
          onSubmitted: (_) => _check(),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(onPressed: _check, icon: const Icon(Icons.search), label: const Text('Analyze')),
        const SizedBox(height: 16),
        if (_result != null) ...[
          Row(children: [
            Icon(risky ? Icons.warning_amber_rounded : Icons.verified_user, color: risky ? Colors.amber : Colors.lightGreen),
            const SizedBox(width: 8),
            Text(risky ? 'Potentially risky' : 'Looks OK'),
          ]),
          const SizedBox(height: 8),
          ..._result!.reasons.map((r) => ListTile(leading: const Icon(Icons.flag), title: Text(r))).toList(),
        ] else ...[
          const Text('Enter a URL to run phishing heuristics.'),
        ]
      ],
    );
  }
}
