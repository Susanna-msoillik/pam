import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';

import 'data/app_user.dart';
import 'data/route_repository.dart';
import 'data/booking_repository.dart';
import 'models/route_details_model.dart';
import 'screens/auth.dart';
import 'screens/booking_form.dart';
import 'screens/home.dart';
import 'screens/my_trips.dart';
import 'screens/profile.dart';
import 'screens/publish_route.dart';
import 'screens/route_details.dart';
import 'screens/route_search.dart';

GoRouter createRouter({
  required String initialLocation,
  Listenable? refreshListenable,
  GoRouterRedirect? redirect,
}) => GoRouter(
  initialLocation: initialLocation,
  refreshListenable: refreshListenable,
  redirect: redirect,
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Страница не найдена')),
    body: Center(
      child: TextButton(
        onPressed: () => context.go('/routes'),
        child: const Text('К поездкам'),
      ),
    ),
  ),
  routes: [
    GoRoute(path: '/login', builder: (_, _) => const AuthPage()),
    StatefulShellRoute.indexedStack(
      builder: (_, _, shell) => HomePage(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/routes',
              builder: (context, _) => RouteSearchPage(
                onOpen: (r) => context.push('/routes/${r.id}'),
                onPublish: () => context.push('/routes/new'),
              ),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (_, _) => const PublishRoutePage(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) => _trip(
                    context,
                    state.pathParameters['id']!,
                    const RouteDetailsPage(),
                  ),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      builder: (context, state) => _trip(
                        context,
                        state.pathParameters['id']!,
                        const RouteEditPage(),
                      ),
                    ),
                    GoRoute(
                      path: 'book',
                      builder: (context, state) => _trip(
                        context,
                        state.pathParameters['id']!,
                        const BookingFormPage(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/trips',
              builder: (context, _) =>
                  MyTripsPage(onOpen: (r) => context.push('/routes/${r.id}')),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/profile', builder: (_, _) => const ProfilePage()),
          ],
        ),
      ],
    ),
  ],
);
Widget _trip(BuildContext context, String id, Widget child) =>
    ChangeNotifierProvider(
      create: (_) => RouteDetailsModel(
        context.read<RouteRepository>(),
        context.read<BookingRepository>(),
        id,
        context.read<AppUser>().id,
      )..load(),
      child: child,
    );
