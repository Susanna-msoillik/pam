import 'package:flutter/material.dart';

import 'screens/route_search.dart';
import 'screens/route_details.dart';
import 'screens/booking_form.dart';

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
        builder: (context) => RouteSearchPage(
          onOpen: (route) => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => RouteDetailsPage(
                route: route,
                onBook: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => BookingFormPage(route: route),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
