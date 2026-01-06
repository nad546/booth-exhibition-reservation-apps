import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/db_service.dart';

// Simple auth state: store username & role in secure storage
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());

class AuthState {
  final String? username;
  final String? role;
  AuthState({this.username, this.role});
}

class AuthNotifier extends StateNotifier<AuthState> {
  final _storage = const FlutterSecureStorage();
  AuthNotifier() : super(AuthState(username: null, role: null)) {
    _load();
  }

  Future<void> _load() async {
    final username = await _storage.read(key: 'username');
    final role = await _storage.read(key: 'role');
    state = AuthState(username: username, role: role);
  }

  Future<String?> login(String username, String password) async {
    final db = DBService();
    final res = await db.query('users', where: 'username = ? AND password = ?', whereArgs: [username, password]);
    if (res.isNotEmpty) {
      final r = res.first;
      final role = r['role'] as String? ?? 'exhibitor';
      await _storage.write(key: 'username', value: username);
      await _storage.write(key: 'role', value: role);
      state = AuthState(username: username, role: role);
      return null;
    } else {
      return 'Invalid credentials';
    }
  }

  Future<String?> register(String username, String password, String displayName, String role) async {
    final db = DBService();
    try {
      await db.insert('users', {'username': username, 'password': password, 'display_name': displayName, 'role': role});
      await _storage.write(key: 'username', value: username);
      await _storage.write(key: 'role', value: role);
      state = AuthState(username: username, role: role);
      return null;
    } catch (e) {
      return 'Username may already exist';
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'username');
    await _storage.delete(key: 'role');
    state = AuthState(username: null, role: null);
  }
}