import 'package:flutter/material.dart';

import 'screens/route_search.dart';

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
      home: const RouteSearchPage(),
    );
  }
}
