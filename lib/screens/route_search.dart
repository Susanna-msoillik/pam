import 'package:flutter/material.dart';

import '../data/car_route.dart';
import '../data/mock_data.dart';
import '../widgets/route_card.dart';

class RouteSearchPage extends StatelessWidget {
  final ValueChanged<CarRoute>? onOpen;
  final VoidCallback? onPublish;

  const RouteSearchPage({super.key, this.onOpen, this.onPublish});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Найти поездку')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const TextField(
            decoration: InputDecoration(
              labelText: 'Откуда',
              prefixIcon: Icon(Icons.trip_origin),
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Куда',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Дата поездки',
              hintText: 'дд.мм.гггг',
              prefixIcon: Icon(Icons.calendar_today),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.search),
            label: const Text('Найти'),
          ),
          const SizedBox(height: 16),
          Text(
            'Ближайшие поездки',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ...mockRoutes.map(
            (route) =>
                RouteCard(route: route, onTap: () => onOpen?.call(route)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onPublish ?? () {},
        icon: const Icon(Icons.add),
        label: const Text('Предложить поездку'),
      ),
    );
  }
}
