import 'package:flutter/material.dart';

import '../data/car_route.dart';
import 'booking_form.dart';
import 'my_trips.dart';
import 'profile.dart';
import 'publish_route.dart';
import 'route_details.dart';
import 'route_search.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  void _open(CarRoute route) {
    Navigator.of(context).push(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          RouteSearchPage(
            onOpen: _open,
            onPublish: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const PublishRoutePage()),
            ),
          ),
          MyTripsPage(onOpen: _open),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.search), label: 'Поиск'),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            label: 'Мои поездки',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}
