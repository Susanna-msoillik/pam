import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';

import '../data/booking.dart';
import '../data/result.dart';
import '../models/route_details_model.dart';
import '../models/bookings_model.dart';
import '../widgets/load_state.dart';
import '../widgets/route_info.dart';

class BookingFormPage extends StatefulWidget {
  const BookingFormPage({super.key});
  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  final _form = GlobalKey<FormState>();
  final _seats = TextEditingController(text: '1');
  bool _saving = false;
  String? _error;
  @override
  void dispose() {
    _seats.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving || !_form.currentState!.validate()) return;
    final details = context.read<RouteDetailsModel>();
    if (!details.canBook) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await context.read<BookingsModel>().book(
      details.routeId,
      int.parse(_seats.text),
    );
    if (!mounted) return;
    if (result is Err<Booking>) {
      setState(() {
        _saving = false;
        _error = result.message;
      });
      await details.load();
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Места забронированы')));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<RouteDetailsModel>();
    final route = model.route;
    return Scaffold(
      appBar: AppBar(title: const Text('Бронирование')),
      body: LoadState(
        loading: model.loading,
        error: model.error,
        onRetry: model.load,
        child: route == null
            ? const SizedBox.shrink()
            : Form(
                key: _form,
                child: ListView(
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
                      value: '${route.price.toStringAsFixed(2)} MDL',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _seats,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Количество мест',
                      ),
                      validator: (v) {
                        final seats = int.tryParse(v ?? '') ?? 0;
                        if (seats < 1) return 'Минимум одно место';
                        return seats > model.freeSeats
                            ? 'Недостаточно свободных мест'
                            : null;
                      },
                    ),
                    const SizedBox(height: 24),
                    if (model.ownBooking != null)
                      Text(
                        'У вас уже забронировано мест: ${model.ownBooking!.seats}',
                      ),
                    if (_error != null)
                      Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    FilledButton(
                      onPressed: !_saving && model.canBook ? _submit : null,
                      child: const Text('Подтвердить бронирование'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
