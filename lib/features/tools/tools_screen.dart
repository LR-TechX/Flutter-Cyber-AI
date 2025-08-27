import 'package:flutter/material.dart';
import 'wifi_scan_page.dart';
import 'password_checker_page.dart';
import 'phishing_checker_page.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  int _index = 0;
  final _pages = const [WifiScanPage(), PasswordCheckerPage(), PhishingCheckerPage()];
  final _labels = const ['Wi‑Fi Scan', 'Password', 'Phishing'];
  final _icons = const [Icons.wifi, Icons.password, Icons.shield_moon_outlined];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_labels[_index])),
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: List.generate(_pages.length, (i) => NavigationDestination(icon: Icon(_icons[i]), label: _labels[i])),
      ),
    );
  }
}
