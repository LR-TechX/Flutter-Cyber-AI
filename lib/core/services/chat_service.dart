import 'package:dio/dio.dart';
import '../services/knowledge_base_service.dart';
import '../services/memory_service.dart';
import '../utils/normalizer.dart';

class ChatService {
  final KnowledgeBaseService kb;
  final MemoryService memory;
  final Dio dio;

  ChatService({required this.kb, required this.memory, Dio? dio})
      : dio = dio ?? Dio(BaseOptions(connectTimeout: const Duration(seconds: 15), receiveTimeout: const Duration(seconds: 30)));

  Future<String> send({
    required String message,
    required bool useOnline,
    required String proxyUrl,
  }) async {
    final kbHit = kb.findBest(message);
    if (kbHit != null) {
      return kbHit.answer;
    }

    final memHit = await memory.getAnswer(message);
    if (memHit != null) {
      return memHit;
    }

    if (useOnline && proxyUrl.isNotEmpty) {
      try {
        final url = proxyUrl.endsWith('/') ? '${proxyUrl}chat' : '$proxyUrl/chat';
        final resp = await dio.post(url, data: {'message': message});
        final answer = (resp.data is Map && resp.data['answer'] is String)
            ? resp.data['answer'] as String
            : resp.data.toString();
        await memory.saveAnswer(message, answer);
        return answer;
      } catch (_) {
        // fallthrough to learning message
      }
    }

    await memory.logUnanswered(message);
    return "I'm learning… I don't have that yet. Try rephrasing or enable Online Intelligence in Settings.";
  }
}
