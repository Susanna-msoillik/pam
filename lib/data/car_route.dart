class CarRoute {
  final String id;
  final String driverId;
  final String driverName;
  final String fromCity;
  final String toCity;
  final DateTime departureAt;
  final int seatsTotal;
  final double price;

  const CarRoute({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.fromCity,
    required this.toCity,
    required this.departureAt,
    required this.seatsTotal,
    required this.price,
  });
}
