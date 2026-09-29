import 'package:flutter/material.dart';

import '../data/car_route.dart';
import 'route_info.dart';

class RouteCard extends StatelessWidget {
  final CarRoute route;
  final VoidCallback? onTap;
  final String? status;

  const RouteCard({super.key, required this.route, this.onTap, this.status});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${route.fromCity} → ${route.toCity}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(dateLabel(route.departureAt)),
              const SizedBox(height: 8),
              Row(
                children: [
                  CircleAvatar(child: Text(route.driverName[0])),
                  const SizedBox(width: 12),
                  Expanded(child: Text(route.driverName)),
                  Text(
                    '${route.price.toStringAsFixed(0)} MDL',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              if (status != null) ...[
                const SizedBox(height: 8),
                Text(
                  status!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
