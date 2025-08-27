import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatBubble({super.key, required this.text, required this.isUser, required this.timestamp});

  @override
  Widget build(BuildContext context) {
    final bg = isUser ? AppTheme.neonBlue.withOpacity(0.15) : AppTheme.neonGreen.withOpacity(0.15);
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = BorderRadius.circular(12);
    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          decoration: BoxDecoration(color: bg, borderRadius: radius, border: Border.all(color: isUser ? AppTheme.neonBlue : AppTheme.neonGreen, width: 1)),
          child: Text(text),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            _fmt(timestamp),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54),
          ),
        )
      ],
    );
  }

  String _fmt(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
