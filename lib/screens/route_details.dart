import 'package:flutter/material.dart';

import '../data/car_route.dart';
import '../widgets/route_info.dart';

class RouteDetailsPage extends StatelessWidget {
  final CarRoute route;
  final VoidCallback? onBook;

  const RouteDetailsPage({super.key, required this.route, this.onBook});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Поездка')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Icon(
            Icons.directions_car,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            '${route.fromCity} → ${route.toCity}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          RouteInfo(
            icon: Icons.person_outline,
            label: 'Водитель',
            value: route.driverName,
          ),
          RouteInfo(
            icon: Icons.schedule,
            label: 'Отправление',
            value: dateLabel(route.departureAt),
          ),
          RouteInfo(
            icon: Icons.event_seat_outlined,
            label: 'Свободных мест',
            value: '${route.seatsTotal}',
          ),
          RouteInfo(
            icon: Icons.payments_outlined,
            label: 'За одно место',
            value: '${route.price.toStringAsFixed(0)} MDL',
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onBook ?? () {},
            child: const Text('Забронировать'),
          ),
        ],
      ),
    );
  }
}
