import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/screens/auth_screen.dart';
import '../features/batches/screens/batches_screen.dart';
import '../features/feed/screens/feed_screen.dart';
import '../features/batches/screens/batch_detail_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/auth',
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
        path: '/batches/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BatchDetailScreen(batchId: id);
        },
      ),
    ],
  );
});
