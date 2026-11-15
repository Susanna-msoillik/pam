import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/car_route.dart';
import '../models/routes_model.dart';
import '../widgets/load_state.dart';
import '../widgets/route_card.dart';

class RouteSearchPage extends StatefulWidget {
  final ValueChanged<CarRoute>? onOpen;
  final VoidCallback? onPublish;
  const RouteSearchPage({super.key, this.onOpen, this.onPublish});
  @override
  State<RouteSearchPage> createState() => _RouteSearchPageState();
}

class _RouteSearchPageState extends State<RouteSearchPage> {
  final _from = TextEditingController();
  final _to = TextEditingController();
  DateTime? _date;
  @override
  void dispose() {
    _from.dispose();
    _to.dispose();
    super.dispose();
  }

  void _search() => context.read<RoutesModel>().load(
    from: _from.text.trim(),
    to: _to.text.trim(),
    day: _date,
    clearDate: _date == null,
  );
  @override
  Widget build(BuildContext context) {
    final model = context.watch<RoutesModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Найти поездку')),
      body: LoadState(
        loading: model.loading,
        error: model.error,
        onRetry: model.load,
        child: RefreshIndicator(
          onRefresh: model.load,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: model.routes.length + 1 + (model.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == model.routes.length + 1) {
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
              }
              if (index > 0) {
                return RouteCard(
                  route: model.routes[index - 1],
                  onTap: () => widget.onOpen?.call(model.routes[index - 1]),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _from,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(),
                    decoration: const InputDecoration(
                      labelText: 'Откуда',
                      prefixIcon: Icon(Icons.trip_origin),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _to,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(),
                    decoration: const InputDecoration(
                      labelText: 'Куда',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final now = DateTime.now();
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _date ?? now,
                        firstDate: DateTime(now.year, now.month, now.day),
                        lastDate: now.add(const Duration(days: 365)),
                      );
                      if (date != null && mounted) setState(() => _date = date);
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _date == null
                          ? 'Дата поездки'
                          : '${_date!.day}.${_date!.month}.${_date!.year}',
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _search,
                          icon: const Icon(Icons.search),
                          label: const Text('Найти'),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _from.clear();
                          _to.clear();
                          setState(() => _date = null);
                          _search();
                        },
                        child: const Text('Сбросить'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    model.routes.isEmpty
                        ? 'Поездки не найдены'
                        : 'Ближайшие поездки',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: widget.onPublish,
        icon: const Icon(Icons.add),
        label: const Text('Предложить поездку'),
      ),
    );
  }
}
