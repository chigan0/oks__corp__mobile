import 'package:go_router/go_router.dart';

import '../../features/auth/auth_notifier.dart';
import '../../screens/auth/approval_waiting_screen.dart';
import '../../screens/auth/auth_screen.dart';
import '../../screens/guard/guard_main_screen.dart';
import '../../screens/guard/guard_scanner_screen.dart';
import '../../screens/role_selection/role_selection_screen.dart';
import '../../screens/worker/object_details_screen.dart';
import '../../screens/worker/worker_main_screen.dart';

GoRouter createAppRouter(AuthNotifier authNotifier) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      if (!authNotifier.isInitialized) {
        return null;
      }

      final location = state.matchedLocation;
      final isAuthRoute = location == '/' || location == '/approval-waiting';
      final isAuthenticated = authNotifier.isAuthenticated;

      if (!isAuthenticated && !isAuthRoute) {
        return '/';
      }

      if (location == '/' && authNotifier.isWaitingForApproval) {
        return '/approval-waiting';
      }

      if (location == '/approval-waiting' &&
          !authNotifier.isWaitingForApproval &&
          !authNotifier.isAuthenticated &&
          !authNotifier.isDenied) {
        return '/';
      }

      if (isAuthenticated && isAuthRoute) {
        return '/roles';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/approval-waiting',
        builder: (context, state) => const ApprovalWaitingScreen(),
      ),
      GoRoute(
        path: '/roles',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/guard',
        builder: (context, state) => const GuardMainScreen(),
        routes: [
          GoRoute(
            path: 'scanner',
            builder: (context, state) => const GuardScannerScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/worker',
        builder: (context, state) => const WorkerMainScreen(),
        routes: [
          GoRoute(
            path: 'object/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ObjectDetailsScreen(objectId: id);
            },
          ),
        ],
      ),
    ],
  );
}
