import 'package:flutter/material.dart';

import '../data/car_route.dart';
import '../data/mock_data.dart';
import '../widgets/route_card.dart';

class MyTripsPage extends StatelessWidget {
  final ValueChanged<CarRoute>? onOpen;
  const MyTripsPage({super.key, this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои поездки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Я пассажир', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...mockBookings.map((booking) {
            final route = mockRoutes.firstWhere(
              (route) => route.id == booking.routeId,
            );
            return Column(
              children: [
                RouteCard(
                  route: route,
                  status: booking.status == 'active'
                      ? 'Забронировано мест: ${booking.seats}'
                      : 'Отменено',
                  onTap: () => onOpen?.call(route),
                ),
                if (booking.status == 'active')
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Отменить бронь'),
                    ),
                  ),
              ],
            );
          }),
          const SizedBox(height: 24),
          Text('Я водитель', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...mockRoutes
              .where((route) => route.driverId == currentUserId)
              .map(
                (route) => RouteCard(
                  route: route,
                  status: 'Опубликовано',
                  onTap: () => onOpen?.call(route),
                ),
              ),
        ],
      ),
    );
  }
}
