import 'package:flutter/foundation.dart';

import '../data/booking.dart';
import '../data/booking_repository.dart';
import '../data/car_route.dart';
import '../data/result.dart';
import '../data/route_repository.dart';

class BookingsModel extends ChangeNotifier {
  final BookingRepository repository;
  final RouteRepository routes;
  final String userId;
  BookingsModel(this.repository, this.routes, this.userId);
  List<Booking> _bookings = [];
  List<CarRoute> _published = [];
  List<Booking> get bookings => List.unmodifiable(_bookings);
  List<CarRoute> get published => List.unmodifiable(_published);
  bool loading = false;
  bool saving = false;
  String? error;
  int _request = 0;
  int _bookingPage = 1;
  int _driverPage = 1;
  bool _moreBookings = false;
  bool _morePublished = false;
  bool get hasMore => _moreBookings || _morePublished;
  bool loadingMore = false;
  String? moreError;

  bool _disposed = false;
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> load() async {
    final request = ++_request;
    if (_disposed) return;
    loadingMore = false;
    moreError = null;
    loading = true;
    error = null;
    notifyListeners();
    final booked = await repository.fetchBookings();
    final published = await routes.fetchRoutes(driverId: userId);
    if (request != _request) return;
    switch (booked) {
      case Ok(value: final value):
        _bookings = value;
        _bookingPage = 1;
        _moreBookings = value.length == 20;
      case Err(message: final message):
        error = message;
    }
    switch (published) {
      case Ok(value: final value):
        _published = value;
        _driverPage = 1;
        _morePublished = value.length == 20;
      case Err(message: final message):
        error ??= message;
    }
    loading = false;
    if (hasListeners) notifyListeners();
  }

  Future<Result<Booking>> book(String routeId, int seats) async {
    if (saving) return const Err('Дождитесь завершения операции');
    saving = true;
    notifyListeners();
    final result = await repository.createBooking(routeId, seats);
    if (result is Ok<Booking>) await load();
    saving = false;
    if (hasListeners) notifyListeners();
    return result;
  }

  Future<Result<Booking>> cancel(String id) async {
    if (saving) return const Err('Дождитесь завершения операции');
    saving = true;
    notifyListeners();
    final result = await repository.updateBooking(id, 'cancelled');
    if (result is Ok<Booking>) await load();
    saving = false;
    if (hasListeners) notifyListeners();
    return result;
  }

  Future<void> loadMore() async {
    if (_disposed || loading || loadingMore || !hasMore) return;
    final request = _request;
    loadingMore = true;
    moreError = null;
    if (_moreBookings) {
      final result = await repository.fetchBookings(page: _bookingPage + 1);
      if (_disposed || request != _request) return;
      switch (result) {
        case Ok(value: final value):
          _bookings = [
            ..._bookings,
            ...value.where((b) => !_bookings.any((old) => old.id == b.id)),
          ];
          _bookingPage++;
          _moreBookings = value.length == 20;
        case Err(message: final message):
          moreError = message;
      }
    }
    if (_morePublished) {
      final result = await routes.fetchRoutes(
        driverId: userId,
        page: _driverPage + 1,
      );
      if (_disposed || request != _request) return;
      switch (result) {
        case Ok(value: final value):
          _published = [
            ..._published,
            ...value.where((r) => !_published.any((old) => old.id == r.id)),
          ];
          _driverPage++;
          _morePublished = value.length == 20;
        case Err(message: final message):
          moreError ??= message;
      }
    }
    loadingMore = false;
    if (hasListeners) notifyListeners();
  }
}
