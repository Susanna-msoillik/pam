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

  bool _disposed = false;
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> load() async {
    final request = ++_request;
    if (_disposed) return;
    loading = true;
    error = null;
    notifyListeners();
    final booked = await repository.fetchBookings();
    final published = await routes.fetchRoutes(driverId: userId);
    if (request != _request) return;
    switch (booked) {
      case Ok(value: final value):
        _bookings = value;
      case Err(message: final message):
        error = message;
    }
    switch (published) {
      case Ok(value: final value):
        _published = value;
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
}
