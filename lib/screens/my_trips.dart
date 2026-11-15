import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/car_route.dart';
import '../data/booking.dart';
import '../data/result.dart';
import '../models/bookings_model.dart';
import '../widgets/route_card.dart';
import '../widgets/load_state.dart';
import '../widgets/confirmation.dart';

class MyTripsPage extends StatelessWidget {
  final ValueChanged<CarRoute>? onOpen;
  const MyTripsPage({super.key, this.onOpen});
  @override
  Widget build(BuildContext context) {
    final model = context.watch<BookingsModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Мои поездки')),
      body: LoadState(
        loading: model.loading,
        error: model.error,
        onRetry: model.load,
        child: RefreshIndicator(
          onRefresh: model.load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Text('Я пассажир', style: Theme.of(context).textTheme.titleLarge),
              if (model.bookings.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('У вас пока нет бронирований'),
                ),
              ...model.bookings.map(
                (booking) => Column(
                  children: [
                    if (booking.route != null)
                      RouteCard(
                        route: booking.route!,
                        status: booking.status == 'active'
                            ? 'Забронировано мест: ${booking.seats}'
                            : booking.route!.deleted
                            ? 'Отменено · Поездка удалена'
                            : 'Отменено',
                        onTap: booking.route!.deleted
                            ? null
                            : () => onOpen?.call(booking.route!),
                      )
                    else
                      const ListTile(title: Text('Поездка удалена')),
                    if (booking.status == 'active')
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: model.saving
                              ? null
                              : () async {
                                  if (!await confirmAction(
                                        context,
                                        'Отменить бронирование?',
                                      ) ||
                                      !context.mounted) {
                                    return;
                                  }
                                  final result = await context
                                      .read<BookingsModel>()
                                      .cancel(booking.id);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        result is Err<Booking>
                                            ? result.message
                                            : 'Бронирование отменено',
                                      ),
                                    ),
                                  );
                                },
                          child: const Text('Отменить бронь'),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Я водитель', style: Theme.of(context).textTheme.titleLarge),
              if (model.published.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Вы пока не опубликовали поездки'),
                ),
              ...model.published.map(
                (route) => RouteCard(
                  route: route,
                  status: 'Опубликовано',
                  onTap: () => onOpen?.call(route),
                ),
              ),
              if (model.hasMore)
                Builder(
                  builder: (context) {
                    if (model.moreError != null) {
                      return TextButton(
                        onPressed: model.loadMore,
                        child: Text('${model.moreError} · Повторить'),
                      );
                    }
                    model.loadMore();
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
