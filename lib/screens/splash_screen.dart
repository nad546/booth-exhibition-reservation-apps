import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../widgets/root_scaffold.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 600), _navigate);
  }

  void _navigate() {
    final auth = ref.read(authProvider);
    if (auth.username == null) {
      context.goNamed('guest_home');
    } else {
      context.goNamed('guest_home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return RootScaffold(
      title: 'Welcome',
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SvgPicture.asset('assets/svg/logo.svg', width: 120, height: 120, placeholderBuilder: (_) => const Icon(Icons.event, size: 120)),
          const SizedBox(height: 12),
          const Text('Exhibition Booth Reservation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}