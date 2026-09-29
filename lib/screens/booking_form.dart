import 'package:flutter/material.dart';

import '../data/car_route.dart';
import '../widgets/route_info.dart';

class BookingFormPage extends StatelessWidget {
  final CarRoute route;

  const BookingFormPage({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Бронирование')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            '${route.fromCity} → ${route.toCity}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          RouteInfo(
            icon: Icons.schedule,
            label: 'Отправление',
            value: dateLabel(route.departureAt),
          ),
          RouteInfo(
            icon: Icons.payments_outlined,
            label: 'За одно место',
            value: '${route.price.toStringAsFixed(0)} MDL',
          ),
          const SizedBox(height: 16),
          const TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Количество мест',
              hintText: '1',
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {},
            child: const Text('Подтвердить бронирование'),
          ),
        ],
      ),
    );
  }
}
