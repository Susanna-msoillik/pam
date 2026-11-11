import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'data/app_user.dart';
import 'data/booking_repository.dart';
import 'data/http_api.dart';
import 'data/http_repositories.dart';
import 'data/route_repository.dart';
import 'data/token_store.dart';
import 'models/auth_model.dart';
import 'models/bookings_model.dart';
import 'models/routes_model.dart';
import 'router.dart';
import 'widgets/load_state.dart';

const apiBase = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080',
);
ThemeData appTheme() => ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF156A87)),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final tokens = TokenStore();
  final token = await tokens.read();
  late final AuthModel auth;
  final api = HttpApi(apiBase, tokens, onUnauthorized: () => auth.logout());
  auth = AuthModel(
    api,
    tokens,
    authenticated: token != null && token.isNotEmpty,
  );
  if (auth.authenticated) auth.restore();
  runApp(
    ChangeNotifierProvider.value(
      value: auth,
      child: CarPoolRoot(api: api),
    ),
  );
}

class CarPoolRoot extends StatefulWidget {
  final HttpApi api;
  const CarPoolRoot({super.key, required this.api});
  @override
  State<CarPoolRoot> createState() => _CarPoolRootState();
}

class _CarPoolRootState extends State<CarPoolRoot> {
  late final GoRouter _router;
  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthModel>();
    _router = createRouter(
      initialLocation: auth.authenticated ? '/routes' : '/login',
      refreshListenable: auth,
      redirect: (_, state) {
        if (!auth.authenticated && state.uri.path != '/login') return '/login';
        if (auth.user != null && state.uri.path == '/login') return '/routes';
        return null;
      },
    );
  }

  @override
  void dispose() {
    _router.dispose();
    widget.api.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthModel>();
    if (auth.authenticated && auth.user == null) {
      return MaterialApp(
        theme: appTheme(),
        home: Scaffold(
          appBar: AppBar(title: const Text('CarPool')),
          body: Column(
            children: [
              Expanded(
                child: LoadState(
                  loading: auth.loading,
                  error: auth.error,
                  onRetry: auth.restore,
                  child: const SizedBox.shrink(),
                ),
              ),
              TextButton(
                onPressed: auth.logout,
                child: const Text('Войти заново'),
              ),
            ],
          ),
        ),
      );
    }
    return MultiProvider(
      key: ValueKey(auth.user?.id),
      providers: [
        Provider<RouteRepository>(
          create: (_) => HttpRouteRepository(widget.api),
        ),
        Provider<BookingRepository>(
          create: (_) => HttpBookingRepository(widget.api),
        ),
        if (auth.user != null) ...[
          Provider<AppUser>.value(value: auth.user!),
          ChangeNotifierProvider(
            create: (context) =>
                RoutesModel(context.read<RouteRepository>())..load(),
          ),
          ChangeNotifierProvider(
            create: (context) => BookingsModel(
              context.read<BookingRepository>(),
              context.read<RouteRepository>(),
              auth.user!.id,
            )..load(),
          ),
        ],
      ],
      child: CarPoolApp(router: _router),
    );
  }
}

class CarPoolApp extends StatelessWidget {
  final GoRouter router;
  const CarPoolApp({super.key, required this.router});
  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'CarPool',
    theme: appTheme(),
    routerConfig: router,
  );
}
