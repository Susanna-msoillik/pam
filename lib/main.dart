import 'package:flutter/material.dart';

import 'router.dart';

import 'package:provider/provider.dart';

import 'data/mock_repository.dart';
import 'data/route_repository.dart';
import 'data/booking_repository.dart';
import 'data/app_user.dart';
import 'models/routes_model.dart';
import 'models/bookings_model.dart';

void main() {
  final repository = MockRepository();
  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: repository),
        Provider<AppUser>.value(value: repository.user),
        Provider<RouteRepository>.value(value: repository),
        Provider<BookingRepository>.value(value: repository),
        ChangeNotifierProvider(create: (_) => RoutesModel(repository)..load()),
        ChangeNotifierProvider(
          create: (_) =>
              BookingsModel(repository, repository, repository.user.id)..load(),
        ),
      ],
      child: const CarPoolApp(),
    ),
  );
}

class CarPoolApp extends StatelessWidget {
  const CarPoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CarPool',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF156A87)),
      ),
      routerConfig: router,
    );
  }
}
