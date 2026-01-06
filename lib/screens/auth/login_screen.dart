import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/root_scaffold.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _error;

  @override
  Widget build(BuildContext context) {
    return RootScaffold(
      title: 'Login',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
            controller: _userCtrl,
            decoration: const InputDecoration(labelText: 'Username'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _passCtrl,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          const SizedBox(height: 12),
          if (_error != null)
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ElevatedButton(
            onPressed: () async {
              final username = _userCtrl.text.trim();
              final pass = _passCtrl.text;

              final err = await ref
                  .read(authProvider.notifier)
                  .login(username, pass);

              if (!context.mounted) return;

              if (err != null) {
                setState(() => _error = err);
              } else {
                context.goNamed('guest_home');
              }
            },
            child: const Text('Login'),
          ),
          TextButton(
            onPressed: () => context.goNamed('register'),
            child: const Text('Register'),
          ),
        ]),
      ),
    );
  }
}
