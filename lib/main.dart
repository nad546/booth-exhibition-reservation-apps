import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/db_service.dart';
import 'app_router.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBService().initAndSeed();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch auth state so when it changes we rebuild and recreate router (simple refresh)
    final auth = ref.watch(authProvider);
    final router = createRouter(auth);

    return MaterialApp.router(
      title: 'Exhibition Booth Reservation',
      theme: ThemeData(primarySwatch: Colors.teal),
      routerConfig: router,
    );
  }
}