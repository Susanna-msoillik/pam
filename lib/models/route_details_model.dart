import 'package:flutter/foundation.dart';

import '../data/booking.dart';
import '../data/booking_repository.dart';
import '../data/car_route.dart';
import '../data/result.dart';
import '../data/route_repository.dart';

class RouteDetailsModel extends ChangeNotifier {
  final RouteRepository routes;
  final BookingRepository bookings;
  final String routeId;
  final String userId;
  RouteDetailsModel(this.routes, this.bookings, this.routeId, this.userId);
  CarRoute? route;
  List<Booking> _active = [];
  bool loading = true;
  String? error;
  int get freeSeats =>
      (route?.seatsTotal ?? 0) - _active.fold(0, (sum, b) => sum + b.seats);
  Booking? get ownBooking =>
      _active.where((b) => b.passengerId == userId).firstOrNull;
  bool get isDriver => route?.driverId == userId;
  bool get canBook =>
      !isDriver &&
      ownBooking == null &&
      freeSeats > 0 &&
      (route?.departureAt.isAfter(DateTime.now()) ?? false);

  bool _disposed = false;
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> load() async {
    if (_disposed) return;
    loading = true;
    error = null;
    notifyListeners();
    final result = await routes.fetchRoute(routeId);
    switch (result) {
      case Ok(value: final value):
        route = value;
      case Err(message: final message):
        error = message;
    }
    if (error == null) {
      final result = await bookings.fetchRouteBookings(routeId);
      switch (result) {
        case Ok(value: final value):
          _active = value;
        case Err(message: final message):
          error = message;
      }
    }
    loading = false;
    if (hasListeners) notifyListeners();
  }
}
