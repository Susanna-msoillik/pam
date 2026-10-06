import 'package:flutter/material.dart';

import 'screens/auth.dart';
import 'screens/home.dart';

void main() {
  runApp(const CarPoolApp());
}

class CarPoolApp extends StatelessWidget {
  const CarPoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CarPool',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF156A87)),
      ),
      home: Builder(
        builder: (context) => AuthPage(
          onLogin: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (_) => const HomePage()),
          ),
        ),
      ),
    );
  }
}
