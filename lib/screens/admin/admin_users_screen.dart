import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/db_service.dart';
import '../../widgets/root_scaffold.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final DBService _db = DBService();
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final rows = await _db.getAllUsers();
    setState(() {
      _users = rows;
      _loading = false;
    });
  }

  Future<void> _changeRole(Map<String, dynamic> user) async {
    final newRole = await showDialog<String>(
      context: context,
      builder: (_) {
        String role = user['role'] ?? 'exhibitor';
        return AlertDialog(
          title: Text("Change Role (${user['username']})"),
          content: DropdownButton<String>(
            value: role,
            items: const [
              DropdownMenuItem(value: 'admin', child: Text('Admin')),
              DropdownMenuItem(value: 'organizer', child: Text('Organizer')),
              DropdownMenuItem(value: 'exhibitor', child: Text('Exhibitor')),
            ],
            onChanged: (v) => Navigator.pop(context, v),
          ),
        );
      },
    );

    if (newRole == null) return;

    await _db.updateUserRole(user['id'], newRole);
    _loadUsers();
  }

  Future<void> _deleteUser(Map<String, dynamic> user) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete User"),
        content: Text("Delete ${user['username']}? This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
        ],
      ),
    );

    if (ok != true) return;

    await _db.deleteUser(user['id']);
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return RootScaffold(
      title: "Admin — User Management",
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadUsers,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _users.length,
          itemBuilder: (_, i) {
            final u = _users[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text("${u['username']}  (${u['role']})"),
                subtitle: Text(
                  "${u['display_name'] ?? ''}\n${u['email'] ?? ''}",
                ),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shield),
                      onPressed: () => _changeRole(u),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteUser(u),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
