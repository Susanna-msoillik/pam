import 'booking.dart';
import 'car_route.dart';

const currentUserId = 'u1';
const currentUserName = 'Сусанна Еремеева';

final mockRoutes = [
  for (final (index, cities, driver, price) in [
    (1, ('Кишинёв', 'Бельцы'), 'Андрей Русу', 90.0),
    (2, ('Кишинёв', 'Оргеев'), 'Мария Чобану', 45.0),
    (3, ('Кишинёв', 'Кагул'), 'Виктор Мунтяну', 120.0),
    (4, ('Бельцы', 'Кишинёв'), 'Елена Попеску', 85.0),
    (5, ('Кишинёв', 'Унгены'), 'Даниел Кожокару', 75.0),
    (6, ('Сороки', 'Кишинёв'), 'Алина Коваль', 110.0),
    (7, ('Кишинёв', 'Хынчешты'), currentUserName, 40.0),
    (8, ('Оргеев', 'Кишинёв'), currentUserName, 50.0),
  ])
    CarRoute(
      id: '$index',
      driverId: index >= 7 ? currentUserId : 'u${index + 1}',
      driverName: driver,
      fromCity: cities.$1,
      toCity: cities.$2,
      departureAt: DateTime.now().add(Duration(days: index, hours: 2)),
      seatsTotal: index.isEven ? 4 : 3,
      price: price,
    ),
];

final mockBookings = [
  for (var index = 1; index <= 6; index++)
    Booking(
      id: '$index',
      routeId: '$index',
      passengerId: currentUserId,
      seats: 1,
      status: index == 5 ? 'cancelled' : 'active',
      createdAt: DateTime.now(),
    ),
];
