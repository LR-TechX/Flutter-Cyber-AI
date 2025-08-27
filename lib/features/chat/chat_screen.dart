import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/message.dart';
import '../../core/services/chat_service.dart';
import '../../core/services/knowledge_base_service.dart';
import '../../core/services/memory_service.dart';
import '../../theme/app_theme.dart';
import 'widgets/chat_bubble.dart';
import '../tools/tools_screen.dart';
import '../tips/tips_screen.dart';
import '../settings/settings_screen.dart';

final settingsProvider = StateNotifierProvider<SettingsController, SettingsState>((ref) => SettingsController());

class SettingsState {
  final bool useOnline;
  final String proxyUrl;
  const SettingsState({required this.useOnline, required this.proxyUrl});
  SettingsState copyWith({bool? useOnline, String? proxyUrl}) => SettingsState(
        useOnline: useOnline ?? this.useOnline,
        proxyUrl: proxyUrl ?? this.proxyUrl,
      );
}

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController() : super(const SettingsState(useOnline: false, proxyUrl: ''));
  void setOnline(bool v) => state = state.copyWith(useOnline: v);
  void setProxy(String v) => state = state.copyWith(proxyUrl: v);
}

final _kbProvider = Provider((ref) => KnowledgeBaseService());
final _memoryProvider = Provider((ref) => MemoryService());
final _chatServiceProvider = Provider((ref) => ChatService(kb: ref.read(_kbProvider), memory: ref.read(_memoryProvider)));

class ChatController extends StateNotifier<List<ChatMessage>> {
  final Ref ref;
  ChatController(this.ref) : super(const []);

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await ref.read(_memoryProvider).init();
    await ref.read(_kbProvider).load();
  }

  Future<void> send(String text) async {
    if (text.trim().isEmpty) return;
    final now = DateTime.now();
    final userMsg = ChatMessage(id: 'u$now', text: text, timestamp: now, isUser: true);
    state = [...state, userMsg];

    final settings = ref.read(settingsProvider);
    final reply = await ref.read(_chatServiceProvider).send(message: text, useOnline: settings.useOnline, proxyUrl: settings.proxyUrl);
    final botMsg = ChatMessage(id: 'b${DateTime.now()}', text: reply, timestamp: DateTime.now(), isUser: false);
    state = [...state, botMsg];
  }
}

final chatProvider = StateNotifierProvider<ChatController, List<ChatMessage>>((ref) => ChatController(ref));

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final controller = TextEditingController();
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('CyberAI')),
      body: IndexedStack(index: _tabIndex, children: [
        Column(children: [
          Expanded(
            child: ListView.builder(
              reverse: false,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final m = messages[index];
                return Align(
                  alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: ChatBubble(text: m.text, isUser: m.isUser, timestamp: m.timestamp),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: 'Ask CyberAI…'),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _send,
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.neonGreen),
                  child: const Icon(Icons.send, color: Colors.black),
                )
              ]),
            ),
          )
        ]),
        const ToolsScreen(),
        const TipsScreen(),
        SettingsScreen(onSettingsChanged: (useOnline, url) {
          ref.read(settingsProvider.notifier).setOnline(useOnline);
          ref.read(settingsProvider.notifier).setProxy(url);
        }),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.security), label: 'Tools'),
          NavigationDestination(icon: Icon(Icons.tips_and_updates_outlined), label: 'Tips'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  void _send() {
    final text = controller.text;
    controller.clear();
    ref.read(chatProvider.notifier).send(text);
  }
}
