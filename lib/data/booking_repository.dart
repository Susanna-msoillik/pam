import 'booking.dart';
import 'result.dart';

abstract interface class BookingRepository {
  Future<Result<List<Booking>>> fetchBookings({int page = 1, int limit = 20});
  Future<Result<List<Booking>>> fetchRouteBookings(String routeId);
  Future<Result<Booking>> fetchBooking(String id);
  Future<Result<Booking>> createBooking(String routeId, int seats);
  Future<Result<Booking>> updateBooking(String id, String status);
  Future<Result<void>> deleteBooking(String id);
}
