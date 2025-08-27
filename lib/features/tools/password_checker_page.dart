import 'package:flutter/material.dart';
import '../../core/services/password_service.dart';

class PasswordCheckerPage extends StatefulWidget {
  const PasswordCheckerPage({super.key});

  @override
  State<PasswordCheckerPage> createState() => _PasswordCheckerPageState();
}

class _PasswordCheckerPageState extends State<PasswordCheckerPage> {
  final TextEditingController _controller = TextEditingController();
  PasswordScore? _score;
  final _svc = PasswordService();

  void _evaluate() {
    setState(() => _score = _svc.evaluate(_controller.text));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _controller,
          obscureText: true,
          decoration: const InputDecoration(hintText: 'Enter a password'),
          onChanged: (_) => _evaluate(),
        ),
        const SizedBox(height: 12),
        if (_score != null) ...[
          Text('Score: ${_score!.score} / 100'),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: _score!.score / 100.0),
          const SizedBox(height: 6),
          Text('Entropy: ${_score!.entropyBits.toStringAsFixed(1)} bits'),
          const SizedBox(height: 12),
          Text('Suggestions', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          ..._score!.suggestions.map((s) => ListTile(leading: const Icon(Icons.tips_and_updates_outlined), title: Text(s))),
        ] else ...[
          const Text('Type a password to see the evaluation.'),
        ]
      ],
    );
  }
}
