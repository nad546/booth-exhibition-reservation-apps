import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/root_scaffold.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  String _role = 'exhibitor';
  String? _error;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _userCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    final display = _nameCtrl.text.trim();

    if (username.isEmpty || pass.isEmpty || display.isEmpty) {
      setState(() => _error = 'All fields are required');
      return;
    }

    final err = await ref
        .read(authProvider.notifier)
        .register(username, pass, display, _role);

    if (!mounted) return;

    if (err != null) {
      setState(() => _error = err);
    } else {
      context.goNamed('guest_home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return RootScaffold(
      title: 'Register',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
            const SizedBox(height: 8),

            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Display name'),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: _role,
              items: const [
                DropdownMenuItem(
                    value: 'exhibitor', child: Text('Exhibitor')),
                DropdownMenuItem(
                    value: 'organizer', child: Text('Organizer')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (v) => setState(() => _role = v ?? 'exhibitor'),
              decoration: const InputDecoration(labelText: 'Role'),
            ),

            const SizedBox(height: 12),

            if (_error != null)
              Text(_error!,
                  style: const TextStyle(color: Colors.red, fontSize: 13)),

            const SizedBox(height: 6),

            ElevatedButton(
              onPressed: _submit,
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
