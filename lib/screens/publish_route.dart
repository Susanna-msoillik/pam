import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../widgets/route_info.dart';

class PublishRoutePage extends StatefulWidget {
  const PublishRoutePage({super.key});
  @override
  State<PublishRoutePage> createState() => _PublishRoutePageState();
}

class _PublishRoutePageState extends State<PublishRoutePage> {
  final _form = GlobalKey<FormState>();
  final _from = TextEditingController();
  final _to = TextEditingController();
  final _date = TextEditingController();
  final _seats = TextEditingController(text: '3');
  final _price = TextEditingController();
  DateTime? _departure;
  @override
  void dispose() {
    for (final c in [_from, _to, _date, _seats, _price]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final day = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (day == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
    );
    if (time == null || !mounted) return;
    _departure = DateTime(day.year, day.month, day.day, time.hour, time.minute);
    _date.text = dateLabel(_departure!);
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Поездка опубликована')));
    context.pop();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Предложить поездку')),
    body: Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Куда едем?', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          TextFormField(
            controller: _from,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Откуда'),
            validator: (v) => v == null || v.trim().isEmpty
                ? 'Введите город отправления'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _to,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Куда'),
            validator: (v) {
              if (v == null || v.trim().isEmpty)
                return 'Введите город назначения';
              return v.trim().toLowerCase() == _from.text.trim().toLowerCase()
                  ? 'Города должны отличаться'
                  : null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _date,
            readOnly: true,
            onTap: _pickDate,
            decoration: const InputDecoration(
              labelText: 'Дата и время',
              suffixIcon: Icon(Icons.calendar_today),
            ),
            validator: (_) =>
                _departure != null && _departure!.isAfter(DateTime.now())
                ? null
                : 'Выберите будущую дату и время',
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _seats,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(labelText: 'Количество мест'),
            validator: (v) =>
                (int.tryParse(v ?? '') ?? 0) >= 1 ? null : 'Минимум одно место',
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Цена за место, MDL'),
            validator: (v) {
              final price = double.tryParse((v ?? '').replaceAll(',', '.'));
              return price != null && price.isFinite && price > 0
                  ? null
                  : 'Введите положительную цену';
            },
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _submit, child: const Text('Опубликовать')),
        ],
      ),
    ),
  );
}
