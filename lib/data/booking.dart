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

  factory Booking.fromJson(Map<String, dynamic> data) => Booking(
    id: (data['id'] as int).toString(),
    routeId: (data['routeId'] as int).toString(),
    passengerId: (data['passengerId'] as int).toString(),
    seats: data['seats'] as int,
    status: data['status'] as String,
    createdAt: DateTime.parse(data['createdAt'] as String).toLocal(),
    route: data['route'] == null
        ? null
        : CarRoute.fromJson(data['route'] as Map<String, dynamic>),
  );
}
