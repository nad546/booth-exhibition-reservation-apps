import 'package:flutter/material.dart';
import '../widgets/root_scaffold.dart';

class AccessDeniedScreen extends StatelessWidget {
  const AccessDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RootScaffold(
      title: 'Access Denied',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.block, size: 72, color: Colors.redAccent),
            const SizedBox(height: 12),
            const Text('Access denied', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('You do not have permission to access this page. Contact an administrator if you believe this is an error.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Go back'),
            ),
          ]),
        ),
      ),
    );
  }
}