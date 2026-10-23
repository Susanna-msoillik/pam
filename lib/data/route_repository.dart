import 'car_route.dart';
import 'result.dart';

abstract interface class RouteRepository {
  Future<Result<List<CarRoute>>> fetchRoutes({
    int page = 1,
    int limit = 20,
    String? fromCity,
    String? toCity,
    DateTime? date,
    String? driverId,
  });
  Future<Result<CarRoute>> fetchRoute(String id);
  Future<Result<CarRoute>> createRoute(CarRoute route);
  Future<Result<CarRoute>> updateRoute(CarRoute route);
  Future<Result<void>> deleteRoute(String id);
}
