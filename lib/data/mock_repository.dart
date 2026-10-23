import 'app_user.dart';
import 'booking.dart';
import 'booking_repository.dart';
import 'car_route.dart';
import 'mock_data.dart';
import 'result.dart';
import 'route_repository.dart';

class MockRepository implements RouteRepository, BookingRepository {
  final user = const AppUser(
    id: currentUserId,
    name: currentUserName,
    email: 'susanna@example.com',
  );
  final _routes = [...mockRoutes];
  final _bookings = [...mockBookings];
  bool simulateError = false;
  int _nextRoute = 9;
  int _nextBooking = 7;

  Future<Result<T>> _request<T>(Result<T> Function() action) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return simulateError
        ? const Err('Не удалось соединиться с сервером')
        : action();
  }

  Booking _withRoute(Booking b) => Booking(
    id: b.id,
    routeId: b.routeId,
    passengerId: b.passengerId,
    seats: b.seats,
    status: b.status,
    createdAt: b.createdAt,
    route: _routes.where((r) => r.id == b.routeId).firstOrNull,
  );

  @override
  Future<Result<List<CarRoute>>> fetchRoutes({
    int page = 1,
    int limit = 20,
    String? fromCity,
    String? toCity,
    DateTime? date,
    String? driverId,
  }) => _request(
    () => Ok(
      _routes
          .where(
            (r) =>
                (fromCity == null ||
                    r.fromCity.toLowerCase().contains(
                      fromCity.toLowerCase(),
                    )) &&
                (toCity == null ||
                    r.toCity.toLowerCase().contains(toCity.toLowerCase())) &&
                (driverId == null || r.driverId == driverId) &&
                (date == null ||
                    (r.departureAt.year == date.year &&
                        r.departureAt.month == date.month &&
                        r.departureAt.day == date.day)),
          )
          .skip((page - 1) * limit)
          .take(limit)
          .toList(),
    ),
  );
  @override
  Future<Result<CarRoute>> fetchRoute(String id) => _request(() {
    final r = _routes.where((r) => r.id == id).firstOrNull;
    return r == null ? const Err('Поездка не найдена') : Ok(r);
  });
  @override
  Future<Result<CarRoute>> createRoute(CarRoute route) => _request(() {
    final created = CarRoute(
      id: '${_nextRoute++}',
      driverId: user.id,
      driverName: user.name,
      fromCity: route.fromCity,
      toCity: route.toCity,
      departureAt: route.departureAt,
      seatsTotal: route.seatsTotal,
      price: route.price,
    );
    _routes.insert(0, created);
    return Ok(created);
  });
  bool _hasActive(String id) =>
      _bookings.any((b) => b.routeId == id && b.status == 'active');
  @override
  Future<Result<CarRoute>> updateRoute(CarRoute route) => _request(() {
    final index = _routes.indexWhere(
      (r) => r.id == route.id && r.driverId == user.id,
    );
    if (index < 0) return const Err('Поездка не найдена');
    if (_hasActive(route.id)) {
      return const Err('Сначала отмените активные брони');
    }
    _routes[index] = route;
    return Ok(route);
  });
  @override
  Future<Result<void>> deleteRoute(String id) => _request(() {
    if (_hasActive(id)) return const Err('Сначала отмените активные брони');
    if (!_routes.any((r) => r.id == id && r.driverId == user.id)) {
      return const Err('Поездка не найдена');
    }
    _routes.removeWhere((r) => r.id == id);
    return const Ok(null);
  });
  @override
  Future<Result<List<Booking>>> fetchBookings({int page = 1, int limit = 20}) =>
      _request(
        () => Ok(
          _bookings
              .where((b) => b.passengerId == user.id)
              .skip((page - 1) * limit)
              .take(limit)
              .map(_withRoute)
              .toList(),
        ),
      );
  @override
  Future<Result<List<Booking>>> fetchRouteBookings(String routeId) => _request(
    () => Ok(
      _bookings
          .where((b) => b.routeId == routeId && b.status == 'active')
          .toList(),
    ),
  );
  @override
  Future<Result<Booking>> fetchBooking(String id) => _request(() {
    final b = _bookings
        .where((b) => b.id == id && b.passengerId == user.id)
        .firstOrNull;
    return b == null ? const Err('Бронирование не найдено') : Ok(_withRoute(b));
  });
  @override
  Future<Result<Booking>> createBooking(String routeId, int seats) =>
      _request(() {
        final r = _routes.where((r) => r.id == routeId).firstOrNull;
        if (r == null) return const Err('Поездка не найдена');
        if (r.driverId == user.id) {
          return const Err('Нельзя бронировать свою поездку');
        }
        final active = _bookings.where(
          (b) => b.routeId == routeId && b.status == 'active',
        );
        final own = active.where((b) => b.passengerId == user.id).firstOrNull;
        if (own != null) return Ok(_withRoute(own));
        if (!r.departureAt.isAfter(DateTime.now())) {
          return const Err('Поездка уже началась');
        }
        if (seats < 1 ||
            seats > r.seatsTotal - active.fold(0, (sum, b) => sum + b.seats)) {
          return const Err('Недостаточно свободных мест');
        }
        final b = Booking(
          id: '${_nextBooking++}',
          routeId: routeId,
          passengerId: user.id,
          seats: seats,
          status: 'active',
          createdAt: DateTime.now(),
        );
        _bookings.insert(0, b);
        return Ok(_withRoute(b));
      });
  @override
  Future<Result<Booking>> updateBooking(String id, String status) =>
      _request(() {
        final index = _bookings.indexWhere(
          (b) => b.id == id && b.passengerId == user.id,
        );
        if (index < 0) return const Err('Бронирование не найдено');
        if (status != 'cancelled') {
          return const Err('Можно только отменить бронь');
        }
        final old = _bookings[index];
        final b = Booking(
          id: old.id,
          routeId: old.routeId,
          passengerId: old.passengerId,
          seats: old.seats,
          status: status,
          createdAt: old.createdAt,
        );
        _bookings[index] = b;
        return Ok(_withRoute(b));
      });
  @override
  Future<Result<void>> deleteBooking(String id) => _request(() {
    if (!_bookings.any((b) => b.id == id && b.passengerId == user.id)) {
      return const Err('Бронирование не найдено');
    }
    _bookings.removeWhere((b) => b.id == id);
    return const Ok(null);
  });
}
