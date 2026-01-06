import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../services/db_service.dart';
import '../../models/application_model.dart';
import '../../widgets/root_scaffold.dart';

class MyApplicationsScreen extends ConsumerWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    return RootScaffold(
      title: 'My Applications',
      child: FutureBuilder<List<ApplicationModel>>(
        future: _loadApplications(auth.username),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          final list = snap.data ?? [];
          if (list.isEmpty) return const Center(child: Text('No applications'));
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final a = list[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text('${a.companyName} - Booth ${a.boothId}'),
                  subtitle: Text('Status: ${a.status}'),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<ApplicationModel>> _loadApplications(String? username) async {
    if (username == null) return [];
    final db = DBService();
    final users = await db.query('users', where: 'username = ?', whereArgs: [username]);
    if (users.isEmpty) return [];
    final id = users.first['id'] as int;
    final rows = await db.query('applications', where: 'exhibitor_id = ?', whereArgs: [id]);
    return rows.map((r) => ApplicationModel.fromMap(r)).toList();
  }
}