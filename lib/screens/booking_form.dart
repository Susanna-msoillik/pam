import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../data/car_route.dart';
import '../widgets/route_info.dart';

class BookingFormPage extends StatefulWidget {
  final CarRoute route;
  const BookingFormPage({super.key, required this.route});
  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  final _form = GlobalKey<FormState>();
  final _seats = TextEditingController(text: '1');
  @override
  void dispose() {
    _seats.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Места забронированы')));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final route = widget.route;
    return Scaffold(
      appBar: AppBar(title: const Text('Бронирование')),
      body: Form(
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
              value: '${route.price.toStringAsFixed(0)} MDL',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _seats,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Количество мест'),
              validator: (v) {
                final seats = int.tryParse(v ?? '') ?? 0;
                if (seats < 1) return 'Минимум одно место';
                return seats > route.seatsTotal
                    ? 'Недостаточно свободных мест'
                    : null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              child: const Text('Подтвердить бронирование'),
            ),
          ],
        ),
      ),
    );
  }
}
