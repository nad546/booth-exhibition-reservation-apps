import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/application_model.dart';
import '../services/db_service.dart';

final myApplicationsProvider = FutureProvider.family<List<ApplicationModel>, int>((ref, exhibitorId) async {
  final db = DBService();
  final rows = await db.query('applications', where: 'exhibitor_id = ?', whereArgs: [exhibitorId]);
  return rows.map((r) => ApplicationModel.fromMap(r)).toList();
});

final applicationsForExhibitionProvider = FutureProvider.family<List<ApplicationModel>, int>((ref, exhibitionId) async {
  final db = DBService();
  final rows = await db.query('applications', where: 'exhibition_id = ?', whereArgs: [exhibitionId]);
  return rows.map((r) => ApplicationModel.fromMap(r)).toList();
});