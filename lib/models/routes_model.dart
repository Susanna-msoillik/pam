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
  int _page = 1;
  bool hasMore = false;
  bool loadingMore = false;
  String? moreError;

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
    loadingMore = false;
    moreError = null;
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
        _page = 1;
        hasMore = value.length == 20;
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

  Future<void> loadMore() async {
    if (_disposed || loading || loadingMore || !hasMore) return;
    final request = _request;
    loadingMore = true;
    moreError = null;
    final result = await repository.fetchRoutes(
      page: _page + 1,
      fromCity: fromCity,
      toCity: toCity,
      date: date,
    );
    if (_disposed || request != _request) return;
    switch (result) {
      case Ok(value: final value):
        _routes = [
          ..._routes,
          ...value.where((r) => !_routes.any((old) => old.id == r.id)),
        ];
        _page++;
        hasMore = value.length == 20;
      case Err(message: final message):
        moreError = message;
    }
    loadingMore = false;
    if (hasListeners) notifyListeners();
  }

  Future<Result<CarRoute>> update(CarRoute route) async {
    final result = await repository.updateRoute(route);
    if (result is Ok<CarRoute>) await load();
    return result;
  }

  Future<Result<void>> remove(String id) async {
    final result = await repository.deleteRoute(id);
    if (result is Ok<void>) await load();
    return result;
  }
}
