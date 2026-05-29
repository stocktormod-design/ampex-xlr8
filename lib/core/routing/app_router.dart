import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/orders/presentation/order_detail_screen.dart';
import '../../features/orders/presentation/orders_list_screen.dart';
import '../../features/projects/presentation/drawing_viewer_screen.dart';
import '../../features/projects/presentation/project_detail_screen.dart';
import '../../features/projects/presentation/projects_list_screen.dart';
import '../../features/shell/presentation/app_tab_shell.dart';
import '../../features/shell/presentation/home_screen.dart';
import '../auth/auth_repository.dart';
import 'routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: Routes.home,
    refreshListenable: _AuthRefreshListenable(authRepo),
    redirect: (context, state) {
      final loggedIn = authRepo.currentSession != null;
      final onLogin = state.matchedLocation == Routes.login;

      if (!loggedIn && !onLogin) return Routes.login;
      if (loggedIn && onLogin) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppTabShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.orders,
                builder: (context, state) => const OrdersListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => OrderDetailScreen(
                      id: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.projects,
                builder: (context, state) => const ProjectsListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => ProjectDetailScreen(
                      id: state.pathParameters['id']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'tegning/:drawingId',
                        builder: (context, state) => DrawingViewerScreen(
                          projectId: state.pathParameters['id']!,
                          drawingId: state.pathParameters['drawingId']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(AuthRepository repo) {
    _sub = repo.authStateChanges().listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
