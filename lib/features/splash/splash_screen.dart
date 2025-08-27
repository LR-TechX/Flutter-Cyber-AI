import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../chat/chat_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => const ChatScreen(),
          transitionsBuilder: (context, anim, _, child) => FadeTransition(opacity: anim, child: child),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/anim/launch.json', width: 220),
            const SizedBox(height: 16),
            Text('Initializing CyberAI…', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
