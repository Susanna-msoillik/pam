import 'package:flutter/foundation.dart';

import '../data/car_route.dart';
import '../data/result.dart';
import '../data/route_repository.dart';

class RoutesModel extends ChangeNotifier {
  final RouteRepository repository;
  RoutesModel(this.repository);
  List<CarRoute> _routes = [];
  List<CarRoute> get routes => List.unmodifiable(_routes);
  bool loading = false;
  String? error;
  String fromCity = '';
  String toCity = '';
  DateTime? date;
  int _request = 0;

  bool _disposed = false;
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> load({
    String? from,
    String? to,
    DateTime? day,
    bool clearDate = false,
  }) async {
    fromCity = from ?? fromCity;
    toCity = to ?? toCity;
    date = clearDate ? null : day ?? date;
    final request = ++_request;
    if (_disposed) return;
    loading = true;
    error = null;
    notifyListeners();
    final result = await repository.fetchRoutes(
      fromCity: fromCity,
      toCity: toCity,
      date: date,
    );
    if (request != _request) return;
    switch (result) {
      case Ok(value: final value):
        _routes = value;
      case Err(message: final message):
        error = message;
    }
    loading = false;
    if (hasListeners) notifyListeners();
  }

  Future<Result<CarRoute>> create(CarRoute route) async {
    final result = await repository.createRoute(route);
    if (result is Ok<CarRoute>) await load();
    return result;
  }
}
