import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/orders/presentation/orders_placeholder_screen.dart';
import '../../features/projects/presentation/projects_placeholder_screen.dart';
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
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: Routes.orders,
        builder: (context, state) => const OrdersPlaceholderScreen(),
      ),
      GoRoute(
        path: Routes.orderDetail,
        builder: (context, state) => OrdersPlaceholderScreen(
          id: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: Routes.projects,
        builder: (context, state) => const ProjectsPlaceholderScreen(),
      ),
      GoRoute(
        path: Routes.projectDetail,
        builder: (context, state) => ProjectsPlaceholderScreen(
          id: state.pathParameters['id'],
        ),
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
