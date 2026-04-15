import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/new_batch_screen.dart';
import 'screens/history_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/new-batch',
      builder: (context, state) => const NewBatchScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
  ],
);
