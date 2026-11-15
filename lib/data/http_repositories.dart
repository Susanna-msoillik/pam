import 'booking.dart';
import 'booking_repository.dart';
import 'car_route.dart';
import 'http_api.dart';
import 'result.dart';
import 'route_repository.dart';

class HttpRouteRepository implements RouteRepository {
  final HttpApi api;
  HttpRouteRepository(this.api);
  @override
  Future<Result<List<CarRoute>>> fetchRoutes({
    int page = 1,
    int limit = 20,
    String? fromCity,
    String? toCity,
    DateTime? date,
    String? driverId,
  }) => api.request(
    'GET',
    '/routes',
    (data) => (data['items'] as List)
        .map((value) => CarRoute.fromJson(value as Map<String, dynamic>))
        .toList(),
    query: {
      'page': '$page',
      'limit': '$limit',
      if (fromCity != null && fromCity.isNotEmpty) 'from': fromCity,
      if (toCity != null && toCity.isNotEmpty) 'to': toCity,
      if (date != null)
        'date':
            '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'driverId': ?driverId,
    },
  );
  @override
  Future<Result<CarRoute>> fetchRoute(String id) =>
      api.request('GET', '/routes/$id', CarRoute.fromJson);
  @override
  Future<Result<CarRoute>> createRoute(CarRoute route) =>
      api.request('POST', '/routes', CarRoute.fromJson, body: route.toJson());
  @override
  Future<Result<CarRoute>> updateRoute(CarRoute route) => api.request(
    'PUT',
    '/routes/${route.id}',
    CarRoute.fromJson,
    body: route.toJson(),
  );
  @override
  Future<Result<void>> deleteRoute(String id) =>
      api.request<void>('DELETE', '/routes/$id', (_) {});
}

class HttpBookingRepository implements BookingRepository {
  final HttpApi api;
  HttpBookingRepository(this.api);
  List<Booking> _list(Map<String, dynamic> data) => (data['items'] as List)
      .map((value) => Booking.fromJson(value as Map<String, dynamic>))
      .toList();
  @override
  Future<Result<List<Booking>>> fetchBookings({int page = 1, int limit = 20}) =>
      api.request(
        'GET',
        '/bookings',
        _list,
        query: {'page': '$page', 'limit': '$limit'},
      );
  @override
  Future<Result<List<Booking>>> fetchRouteBookings(String routeId) =>
      api.request('GET', '/routes/$routeId/bookings', _list);
  @override
  Future<Result<Booking>> fetchBooking(String id) =>
      api.request('GET', '/bookings/$id', Booking.fromJson);
  @override
  Future<Result<Booking>> createBooking(String routeId, int seats) =>
      api.request(
        'POST',
        '/bookings',
        Booking.fromJson,
        body: {'routeId': int.parse(routeId), 'seats': seats},
      );
  @override
  Future<Result<Booking>> updateBooking(String id, String status) =>
      api.request(
        'PUT',
        '/bookings/$id',
        Booking.fromJson,
        body: {'status': status},
      );
  @override
  Future<Result<void>> deleteBooking(String id) =>
      api.request<void>('DELETE', '/bookings/$id', (_) {});
}
