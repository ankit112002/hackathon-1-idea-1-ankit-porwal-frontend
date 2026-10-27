import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/admin/calendar_screen.dart';
import '../features/admin/dashboard_screen.dart';
import '../features/admin/events_screen.dart';
import '../features/admin/floor_screen.dart';
import '../features/admin/login_screen.dart';
import '../features/admin/settings_screen.dart';
import '../features/admin/waiter_screen.dart';
import '../features/booking/book_screen.dart';
import '../features/booking/confirm_screen.dart';
import '../features/home/home_screen.dart';
import '../features/manage/manage_screen.dart';
import '../models/staff_role.dart';
import '../providers/app_providers.dart';
import '../repositories/auth_repository.dart';

class _AuthRefresh extends ChangeNotifier {
  void bump() => notifyListeners();
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final ready = ref.watch(supabaseReadyProvider);
  final refresh = _AuthRefresh();
  String? cachedUserId;
  StaffRole? cachedRole;

  if (ready) {
    final subscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (_) {
        cachedUserId = null;
        cachedRole = null;
        refresh.bump();
        ref.invalidate(staffRoleProvider);
      },
    );
    ref.onDispose(subscription.cancel);
  }
  ref.onDispose(refresh.dispose);

  Future<StaffRole?> currentRole() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      cachedUserId = null;
      cachedRole = null;
      return null;
    }
    if (cachedUserId == user.id) return cachedRole;
    cachedRole = await AuthRepository(Supabase.instance.client).currentRole();
    cachedUserId = user.id;
    return cachedRole;
  }

  final router = GoRouter(
    refreshListenable: refresh,
    redirect: (context, state) async {
      final path = state.uri.path;
      final isAdmin = path == '/admin' || path.startsWith('/admin/');
      if (!isAdmin) return null;

      final isLogin = path == '/admin/login';
      if (!ready) return isLogin ? null : '/admin/login';

      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) return isLogin ? null : '/admin/login';

      final role = await currentRole();
      if (role == null) return isLogin ? null : '/admin/login';
      if (path == '/admin/login') {
        return role == StaffRole.waiter ? '/admin/waiter' : '/admin';
      }
      if (role == StaffRole.waiter && path != '/admin/waiter') {
        return '/admin/waiter';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/book', builder: (context, state) => const BookScreen()),
      GoRoute(
        path: '/book/confirm',
        builder: (context, state) => ConfirmScreen(
          token: state.uri.queryParameters['token'] ?? '',
        ),
      ),
      GoRoute(
        path: '/manage/:token',
        builder: (context, state) =>
            ManageScreen(token: state.pathParameters['token'] ?? ''),
      ),
      GoRoute(
        path: '/admin/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/admin/waiter',
        builder: (context, state) => const WaiterScreen(),
      ),
      GoRoute(
        path: '/admin/floor',
        builder: (context, state) => const FloorScreen(),
      ),
      GoRoute(
        path: '/admin/calendar',
        builder: (context, state) => const CalendarScreen(),
      ),
      GoRoute(
        path: '/admin/events',
        builder: (context, state) => const EventsScreen(),
      ),
      GoRoute(
        path: '/admin/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
