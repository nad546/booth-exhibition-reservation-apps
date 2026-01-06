import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';

import 'screens/splash_screen.dart';
import 'screens/guest_home_screen.dart';

import 'screens/exhibition_detail_screen.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';

import 'screens/exhibitor/floorplan_screen.dart';
import 'screens/exhibitor/application_form_screen.dart';
import 'screens/exhibitor/my_applications_screen.dart';

import 'screens/admin/admin_floorplan_manage.dart';
import 'screens/admin/manage_booths_screen.dart';
import 'screens/admin/admin_users_screen.dart'; // 👈 ADDED

import 'screens/organizer/organizer_applications_review.dart';
import 'screens/organizer/create_exhibition_screen.dart';
import 'screens/organizer/manage_exhibitions_screen.dart';

import 'screens/access_denied_screen.dart';

/// Creates router each time auth changes (handled in main via Riverpod)
GoRouter createRouter(AuthState auth) {
  final role = auth.role;
  final loggedIn = auth.username != null;

  return GoRouter(
    initialLocation: '/',
    routes: [

      /// Splash (always allowed)
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (_, __) => const SplashScreen(),
      ),

      /// Public / Guest home
      GoRoute(
        path: '/guest',
        name: 'guest_home',
        builder: (_, __) => const GuestHomeScreen(),
      ),

      /// Exhibition detail (public)
      GoRoute(
        path: '/exhibition/:id',
        name: 'exhibition_detail',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 1;
          return ExhibitionDetailScreen(exhibitionId: id);
        },
      ),

      /// Auth pages
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (_, __) => const RegisterScreen(),
      ),

      // ─────────────────────────────
      // Exhibitor Routes
      // ─────────────────────────────

      GoRoute(
        path: '/floorplan/:exhId',
        name: 'floorplan',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['exhId'] ?? '') ?? 1;
          return FloorplanScreen(exhibitionId: id);
        },
      ),

      GoRoute(
        path: '/apply/:exhId',
        name: 'apply',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['exhId'] ?? '') ?? 1;
          final boothCsv = state.queryParameters['booths'] ?? '';
          return ApplicationFormScreen(
            exhibitionId: id,
            selectedBoothIdsCsv: boothCsv,
          );
        },
      ),

      GoRoute(
        path: '/my-applications',
        name: 'my_applications',
        builder: (_, __) => const MyApplicationsScreen(),
      ),

      // ─────────────────────────────
      // Admin Routes
      // ─────────────────────────────

      GoRoute(
        path: '/admin/floorplan',
        name: 'admin_floorplan',
        builder: (_, __) => const AdminFloorplanManageScreen(),
      ),
      GoRoute(
        path: '/admin/manage-booths',
        name: 'admin_manage_booths',
        builder: (_, __) => const ManageBoothsScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        name: 'admin_users',
        builder: (_, __) => const AdminUsersScreen(),
      ),

      // ─────────────────────────────
      // Organizer Routes
      // ─────────────────────────────

      GoRoute(
        path: '/organizer/applications',
        name: 'organizer_applications',
        builder: (_, __) => const OrganizerApplicationsReviewScreen(),
      ),

      // ✔ Create Exhibition (same screen as before)
      GoRoute(
        path: '/organizer/create-exhibition',
        name: 'organizer_create_exhibition',
        builder: (_, __) => const CreateExhibitionScreen(),
      ),

      // ✔ NEW — Manage Exhibitions Screen
      GoRoute(
        path: '/organizer/manage-exhibitions',
        name: 'organizer_manage_exhibitions',
        builder: (_, __) => const ManageExhibitionsScreen(),
      ),

      /// Access denied
      GoRoute(
        path: '/access-denied',
        name: 'access_denied',
        builder: (_, __) => const AccessDeniedScreen(),
      ),
    ],

    // ─────────────────────────────
    // ROLE-BASED REDIRECT LOGIC
    // ─────────────────────────────
    redirect: (context, state) {
      final loc = state.location;

      // Prevent redirect loops
      if (loc == '/' || loc == '/access-denied') return null;

      // Block login/register if already logged in
      if ((loc == '/login' || loc == '/register') && loggedIn) {
        return '/guest';
      }

      // Exhibitor-only
      final exhibitorProtected = [
        '/apply',
        '/my-applications',
      ];

      if (exhibitorProtected.any(loc.startsWith)) {
        if (!loggedIn) return '/login';
        if (role != 'exhibitor') return '/access-denied';
      }

      // Admin-only
      if (loc.startsWith('/admin')) {
        if (!loggedIn) return '/login';
        if (role != 'admin') return '/access-denied';
      }

      // Organizer-only
      if (loc.startsWith('/organizer')) {
        if (!loggedIn) return '/login';
        if (role != 'organizer') return '/access-denied';
      }

      return null;
    },
  );
}
