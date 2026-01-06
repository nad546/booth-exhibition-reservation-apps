import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exhibition.dart';
import '../services/db_service.dart';

final exhibitionsProvider = FutureProvider<List<Exhibition>>((ref) async {
  final db = DBService();
  final rows = await db.query('exhibitions', where: 'is_published = ?', whereArgs: [1]);
  return rows.map((r) => Exhibition.fromMap(r)).toList();
});

final exhibitionByIdProvider = FutureProvider.family<Exhibition?, int>((ref, id) async {
  final db = DBService();
  final rows = await db.query('exhibitions', where: 'id = ?', whereArgs: [id]);
  if (rows.isEmpty) return null;
  return Exhibition.fromMap(rows.first);
});