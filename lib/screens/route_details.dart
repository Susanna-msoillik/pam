import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/route_details_model.dart';
import '../models/routes_model.dart';
import '../models/bookings_model.dart';
import '../data/result.dart';
import '../widgets/confirmation.dart';
import '../widgets/load_state.dart';
import '../widgets/route_info.dart';

class RouteDetailsPage extends StatelessWidget {
  const RouteDetailsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final model = context.watch<RouteDetailsModel>();
    final route = model.route;
    return Scaffold(
      appBar: AppBar(title: const Text('Поездка')),
      body: LoadState(
        loading: model.loading,
        error: model.error,
        onRetry: model.load,
        child: route == null
            ? const SizedBox.shrink()
            : RefreshIndicator(
                onRefresh: model.load,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  physics: const AlwaysScrollableScrollPhysics(),
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
                      value: '${model.freeSeats}',
                    ),
                    RouteInfo(
                      icon: Icons.payments_outlined,
                      label: 'За одно место',
                      value: '${route.price.toStringAsFixed(2)} MDL',
                    ),
                    const SizedBox(height: 24),
                    if (model.ownBooking != null)
                      Text(
                        'У вас уже забронировано мест: ${model.ownBooking!.seats}',
                      ),
                    if (model.isDriver) ...[
                      const Text('Ваша поездка'),
                      TextButton(
                        onPressed: model.freeSeats == route.seatsTotal
                            ? () async {
                                await context.push('/routes/${route.id}/edit');
                                if (context.mounted) await model.load();
                              }
                            : null,
                        child: const Text('Изменить'),
                      ),
                      TextButton(
                        onPressed: model.freeSeats == route.seatsTotal
                            ? () async {
                                if (!await confirmAction(
                                      context,
                                      'Удалить поездку?',
                                    ) ||
                                    !context.mounted) {
                                  return;
                                }
                                final result = await context
                                    .read<RoutesModel>()
                                    .remove(route.id);
                                if (!context.mounted) return;
                                if (result is Err<void>) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(result.message)),
                                  );
                                } else {
                                  context.read<BookingsModel>().load();
                                  context.go('/routes');
                                }
                              }
                            : null,
                        child: const Text('Удалить'),
                      ),
                      if (model.freeSeats != route.seatsTotal)
                        const Text('Сначала отмените активные брони'),
                    ],
                    if (!model.isDriver &&
                        model.ownBooking == null &&
                        !model.canBook)
                      const Text('Бронирование недоступно'),
                    FilledButton(
                      onPressed: model.canBook
                          ? () async {
                              await context.push('/routes/${route.id}/book');
                              if (context.mounted) {
                                await context.read<RouteDetailsModel>().load();
                              }
                            }
                          : null,
                      child: const Text('Забронировать'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
