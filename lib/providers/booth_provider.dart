import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booth.dart';
import '../services/db_service.dart';

final boothsByExhibitionProvider = FutureProvider.family<List<Booth>, int>((ref, exhibitionId) async {
  final db = DBService();
  final rows = await db.query('booths', where: 'exhibition_id = ?', whereArgs: [exhibitionId]);
  return rows.map((r) => Booth.fromMap(r)).toList();
});