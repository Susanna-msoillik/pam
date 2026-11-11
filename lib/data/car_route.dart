class CarRoute {
  final String id;
  final String driverId;
  final String driverName;
  final String fromCity;
  final String toCity;
  final DateTime departureAt;
  final int seatsTotal;
  final double price;
  final bool deleted;

  const CarRoute({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.fromCity,
    required this.toCity,
    required this.departureAt,
    required this.seatsTotal,
    required this.price,
    this.deleted = false,
  });

  factory CarRoute.fromJson(Map<String, dynamic> data) => CarRoute(
    id: (data['id'] as int).toString(),
    driverId: (data['driverId'] as int).toString(),
    driverName: data['driverName'] as String,
    fromCity: data['fromCity'] as String,
    toCity: data['toCity'] as String,
    departureAt: DateTime.parse(data['departureAt'] as String).toLocal(),
    seatsTotal: data['seatsTotal'] as int,
    price: (data['price'] as num).toDouble(),
    deleted: data['deleted'] as bool? ?? false,
  );
  Map<String, dynamic> toJson() => {
    'fromCity': fromCity,
    'toCity': toCity,
    'departureAt': departureAt.toUtc().toIso8601String(),
    'seatsTotal': seatsTotal,
    'price': price,
  };
}
