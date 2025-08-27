import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/normalizer.dart';

class MemoryService {
  static const String memoryBoxName = 'memory';
  static const String unansweredBoxName = 'unanswered';
  static const String chatHistoryBoxName = 'chat_history';

  Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<String>(memoryBoxName),
      Hive.openBox<String>(unansweredBoxName),
    ]);
  }

  Future<String?> getAnswer(String question) async {
    final normalized = Normalizer.normalizeQuestion(question);
    final box = Hive.box<String>(memoryBoxName);
    return box.get(normalized);
  }

  Future<void> saveAnswer(String question, String answer) async {
    final normalized = Normalizer.normalizeQuestion(question);
    final box = Hive.box<String>(memoryBoxName);
    await box.put(normalized, answer);
  }

  Future<void> logUnanswered(String question) async {
    final box = Hive.box<String>(unansweredBoxName);
    await box.add(question);
  }

  Future<void> clearAll() async {
    await Hive.box<String>(memoryBoxName).clear();
    await Hive.box<String>(unansweredBoxName).clear();
  }

  Future<String> exportAsJson() async {
    final mem = Hive.box<String>(memoryBoxName).toMap().cast<String, String>();
    final unanswered = Hive.box<String>(unansweredBoxName).values.toList();
    final data = {
      'memory': mem,
      'unanswered': unanswered,
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }
}
