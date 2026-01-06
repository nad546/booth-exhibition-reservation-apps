import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    Widget roleBadge(String? role) {
      if (role == null) return const SizedBox.shrink();

      final color = switch (role) {
        'admin' => Colors.red,
        'organizer' => Colors.orange,
        'exhibitor' => Colors.blue,
        _ => Colors.grey,
      };

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          role.toUpperCase(),
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      );
    }

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [

            // ───────── Drawer Header ─────────
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.teal),
              child: Row(
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: SvgPicture.asset(
                      'assets/svg/logo.svg',
                      fit: BoxFit.contain,
                      placeholderBuilder: (_) =>
                      const CircleAvatar(child: Icon(Icons.event)),
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          auth.username ?? 'Guest',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        roleBadge(auth.role),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ───────── Home ─────────
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                context.goNamed('guest_home');
              },
            ),

            const Divider(),

            // ───────── Guest Menu ─────────
            if (auth.username == null) ...[
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text('Login'),
                onTap: () {
                  Navigator.pop(context);
                  context.goNamed('login');
                },
              ),
              ListTile(
                leading: const Icon(Icons.app_registration),
                title: const Text('Register'),
                onTap: () {
                  Navigator.pop(context);
                  context.goNamed('register');
                },
              ),
            ],

            // ───────── Exhibitor Menu ─────────
            if (auth.role == 'exhibitor') ...[
              ListTile(
                leading: const Icon(Icons.assignment),
                title: const Text('My Applications'),
                onTap: () {
                  Navigator.pop(context);
                  context.goNamed('my_applications');
                },
              ),
            ],

            // ───────── Organizer Menu ─────────
            if (auth.role == 'organizer') ...[
              ListTile(
                leading: const Icon(Icons.rule_folder),
                title: const Text('Review Applications'),
                onTap: () {
                  Navigator.pop(context);
                  context.goNamed('organizer_applications');
                },
              ),

              // ✔ Create Exhibition ( SAME page as before )
              ListTile(
                leading: const Icon(Icons.add_box),
                title: const Text('Create Exhibition'),
                onTap: () {
                  Navigator.pop(context);
                  context.goNamed('organizer_create_exhibition');
                },
              ),

              // ✔ Manage Exhibitions ( NEW screen )
              ListTile(
                leading: const Icon(Icons.event_note),
                title: const Text('Manage Exhibitions'),
                onTap: () {
                  Navigator.pop(context);
                  context.goNamed('organizer_manage_exhibitions');
                },
              ),
            ],

            // ───────── Admin Menu ─────────
            if (auth.role == 'admin') ...[
              ListTile(
                leading: const Icon(Icons.map),
                title: const Text('Floorplan Mapping'),
                onTap: () {
                  Navigator.pop(context);
                  context.goNamed('admin_floorplan');
                },
              ),
              ListTile(
                leading: const Icon(Icons.view_agenda),
                title: const Text('Manage Booths'),
                onTap: () {
                  Navigator.pop(context);
                  context.goNamed('admin_manage_booths');
                },
              ),

              // ✅ Replaced — now goes to Admin Users screen
              ListTile(
                leading: const Icon(Icons.manage_accounts),
                title: const Text('User Management'),
                onTap: () {
                  Navigator.pop(context);
                  context.goNamed('admin_users');
                },
              ),
            ],

            const Spacer(),

            // ───────── Logout / Guest Notice ─────────
            if (auth.username != null)
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  await authNotifier.logout();

                  if (!context.mounted) return;

                  Navigator.pop(context);
                  context.goNamed('guest_home');
                },
              )
            else
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Not logged in — login or register to apply for booths.',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
