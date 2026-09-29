import 'package:flutter/material.dart';

class PublishRoutePage extends StatelessWidget {
  const PublishRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Предложить поездку')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Куда едем?', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          const TextField(decoration: InputDecoration(labelText: 'Откуда')),
          const SizedBox(height: 16),
          const TextField(decoration: InputDecoration(labelText: 'Куда')),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Дата и время',
              hintText: 'дд.мм.гггг чч:мм',
            ),
          ),
          const SizedBox(height: 16),
          const TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Количество мест'),
          ),
          const SizedBox(height: 16),
          const TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Цена за место, MDL'),
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: () {}, child: const Text('Опубликовать')),
        ],
      ),
    );
  }
}
