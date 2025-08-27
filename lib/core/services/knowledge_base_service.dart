import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/qa_entry.dart';

class KnowledgeBaseService {
  List<QAEntry> _entries = const [];
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString('assets/data/knowledge_base.json');
    final data = jsonDecode(raw) as List<dynamic>;
    _entries = data
        .whereType<Map<String, dynamic>>()
        .map((e) => QAEntry.fromJson(e))
        .toList(growable: false);
    _loaded = true;
  }

  QAEntry? findBest(String question) {
    if (!_loaded || question.trim().isEmpty) return null;
    final qLower = question.toLowerCase();
    // Exact match first
    for (final e in _entries) {
      if (e.question.toLowerCase() == qLower) return e;
    }
    // Contains match
    for (final e in _entries) {
      if (qLower.contains(e.question.toLowerCase()) ||
          e.question.toLowerCase().contains(qLower)) {
        return e;
      }
    }
    // Token overlap heuristic
    final tokens = qLower.split(RegExp(r'\s+')).toSet();
    QAEntry? best;
    int bestScore = 0;
    for (final e in _entries) {
      final t2 = e.question.toLowerCase().split(RegExp(r'\s+')).toSet();
      final score = tokens.intersection(t2).length;
      if (score > bestScore) {
        bestScore = score;
        best = e;
      }
    }
    if (bestScore >= 2) return best; // require minimal overlap
    return null;
  }
}
