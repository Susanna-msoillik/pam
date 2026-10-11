import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'data/mock_data.dart';
import 'screens/auth.dart';
import 'screens/booking_form.dart';
import 'screens/home.dart';
import 'screens/my_trips.dart';
import 'screens/profile.dart';
import 'screens/publish_route.dart';
import 'screens/route_details.dart';
import 'screens/route_search.dart';

final router = GoRouter(
  initialLocation: '/login',
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
                onOpen: (route) => context.push('/routes/${route.id}'),
                onPublish: () => context.push('/routes/new'),
              ),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (_, _) => const PublishRoutePage(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final route = mockRoutes
                        .where(
                          (route) => route.id == state.pathParameters['id'],
                        )
                        .firstOrNull;
                    return route == null
                        ? const Scaffold(
                            body: Center(child: Text('Поездка не найдена')),
                          )
                        : RouteDetailsPage(
                            route: route,
                            onBook: () =>
                                context.push('/routes/${route.id}/book'),
                          );
                  },
                  routes: [
                    GoRoute(
                      path: 'book',
                      builder: (_, state) {
                        final route = mockRoutes
                            .where(
                              (route) => route.id == state.pathParameters['id'],
                            )
                            .firstOrNull;
                        return route == null
                            ? const Scaffold(
                                body: Center(child: Text('Поездка не найдена')),
                              )
                            : BookingFormPage(route: route);
                      },
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
              builder: (context, _) => MyTripsPage(
                onOpen: (route) => context.push('/routes/${route.id}'),
              ),
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
