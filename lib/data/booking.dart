import 'car_route.dart';

class Booking {
  final String id;
  final String routeId;
  final String passengerId;
  final int seats;
  final String status;
  final DateTime createdAt;
  final CarRoute? route;

  const Booking({
    required this.id,
    required this.routeId,
    required this.passengerId,
    required this.seats,
    required this.status,
    required this.createdAt,
    this.route,
  });
}
