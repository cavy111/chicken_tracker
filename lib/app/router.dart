import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/screens/auth_screen.dart';
import '../features/batches/screens/batches_screen.dart';
import '../features/feed/screens/feed_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/batches/screens/batch_detail_screen.dart';
import '../features/transactions/screens/withdrawals_screen.dart';
import '../features/auth/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/auth',
    redirect: (context, state) {
      final authState = ref.watch(authProvider);
      final isLoggedIn = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/auth';

      // If user is logged in and trying to access auth, redirect to batches
      if (isLoggedIn && isAuthRoute) {
        return '/batches';
      }

      // If user is not logged in and trying to access protected routes, redirect to auth
      if (!isLoggedIn && !isAuthRoute) {
        return '/auth';
      }

      // No redirect needed
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/batches',
        builder: (context, state) => const BatchesScreen(),
      ),
      GoRoute(
        path: '/feed',
        builder: (context, state) => const FeedScreen(),
      ),
      GoRoute(
        path: '/withdrawals',
        builder: (context, state) => const WithdrawalsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/batches/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BatchDetailScreen(batchId: id);
        },
      ),
    ],
  );
});
