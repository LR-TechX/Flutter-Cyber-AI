import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/memory_service.dart';

class SettingsScreen extends StatefulWidget {
  final void Function(bool useOnline, String proxyUrl) onSettingsChanged;
  const SettingsScreen({super.key, required this.onSettingsChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool useOnline = false;
  final TextEditingController proxyCtl = TextEditingController();
  final _memory = MemoryService();

  @override
  void initState() {
    super.initState();
    _memory.init();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SwitchListTile(
          title: const Text('Use Online Intelligence'),
          subtitle: const Text('Route questions to a proxy LLM when local knowledge is insufficient.'),
          value: useOnline,
          onChanged: (v) {
            setState(() => useOnline = v);
            widget.onSettingsChanged(useOnline, proxyCtl.text);
          },
        ),
        TextField(
          controller: proxyCtl,
          decoration: const InputDecoration(labelText: 'LLM Proxy URL (e.g., https://your-proxy.example.com)'),
          onChanged: (_) => widget.onSettingsChanged(useOnline, proxyCtl.text),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () async {
            await _memory.clearAll();
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Learned memory cleared.')));
          },
          icon: const Icon(Icons.delete_forever),
          label: const Text('Clear Learned Memory'),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () async {
            final json = await _memory.exportAsJson();
            await Clipboard.setData(ClipboardData(text: json));
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exported to clipboard as JSON.')));
          },
          icon: const Icon(Icons.file_download),
          label: const Text('Export Memory (JSON)'),
        ),
        const SizedBox(height: 16),
        const ListTile(
          title: Text('About'),
          subtitle: Text('CyberAI v1.0.0 — A cyber-themed AI assistant with offline knowledge.'),
        ),
      ],
    );
  }
}
