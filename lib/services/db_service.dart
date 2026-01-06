import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBService {
  static final DBService _instance = DBService._();
  factory DBService() => _instance;
  DBService._();

  Database? _db;
  String? _dbPath;

  Future<Database> get database async {
    if (_db != null) return _db!;
    await initAndSeed();
    return _db!;
  }

  // =========================================================
  // INIT + SEED
  // =========================================================
  Future<void> initAndSeed() async {
    if (_db != null) return;

    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, "exhibition_booth_management.db");
    _dbPath = path;

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );

    final count = Sqflite.firstIntValue(
      await _db!.rawQuery("SELECT COUNT(*) FROM exhibitions"),
    );

    if (count == 0) {
      await _seed();
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute("""
CREATE TABLE users (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 username TEXT NOT NULL UNIQUE,
 email TEXT,
 password TEXT,
 display_name TEXT,
 role TEXT NOT NULL
);
""");

    await db.execute("""
CREATE TABLE exhibitions (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 title TEXT NOT NULL,
 description TEXT,
 start_date TEXT,
 end_date TEXT,
 is_published INTEGER DEFAULT 1,
 svg_asset TEXT,
 organizer_id INTEGER
);
""");

    await db.execute("""
CREATE TABLE booths (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 booth_code TEXT,
 exhibition_id INTEGER,
 price REAL,
 size TEXT,
 status TEXT DEFAULT 'available',
 x REAL,
 y REAL,
 width REAL,
 height REAL
);
""");

    await db.execute("""
CREATE TABLE applications (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 exhibitor_id INTEGER,
 exhibition_id INTEGER,
 booth_id INTEGER,
 company_name TEXT,
 company_description TEXT,
 exhibit_profile TEXT,
 event_startdate TEXT,
 event_enddate TEXT,
 status TEXT DEFAULT 'pending',
 organizer_reason TEXT
);
""");
  }

  // =========================================================
  // DEMO DATA SEED
  // =========================================================
  Future<void> _seed() async {
    final db = _db!;

    // --- DEMO USERS ---
    await db.insert("users", {
      "username": "admin_demo",
      "email": "admin_demo@mail.com",
      "password": "123456",
      "display_name": "Admin Demo",
      "role": "admin"
    });

    await db.insert("users", {
      "username": "organizer1",
      "email": "organizer1_demo@mail.com",
      "password": "123456",
      "display_name": "Organizer One",
      "role": "organizer"
    });

    await db.insert("users", {
      "username": "organizer2",
      "email": "organizer2_demo@mail.com",
      "password": "123456",
      "display_name": "Organizer Two",
      "role": "organizer"
    });

    await db.insert("users", {
      "username": "exhibitor_demo",
      "email": "exhibitor_demo@mail.com",
      "password": "123456",
      "display_name": "Exhibitor Demo",
      "role": "exhibitor"
    });

    final org1 = await db.query("users",
        where: "username = ?", whereArgs: ["organizer1"]);
    final org2 = await db.query("users",
        where: "username = ?", whereArgs: ["organizer2"]);

    final org1Id = org1.first["id"] as int;
    final org2Id = org2.first["id"] as int;

    // --- EXHIBITIONS ---
    await db.insert("exhibitions", {
      "title": "DIGITAL MARKETING EXPO 2026",
      "description": "A showcase of digital marketing tools.",
      "start_date": "2026-06-10 09:00",
      "end_date": "2026-06-12 17:00",
      "is_published": 1,
      "svg_asset": "assets/svg/expo1.svg",
      "organizer_id": org1Id
    });

    await db.insert("exhibitions", {
      "title": "BOOK FESTIVAL 2026",
      "description": "Books, authors & publishers meetup.",
      "start_date": "2026-09-20 09:00",
      "end_date": "2026-09-22 17:00",
      "is_published": 1,
      "svg_asset": "assets/svg/expo2.svg",
      "organizer_id": org2Id
    });

    // --- BOOTHS (EXPO 1) ---
    for (final b in [
      {"booth_code": "A-01", "exhibition_id": 1, "price": 1500.0, "size": "20sqm", "status": "available", "x": 50, "y": 50, "width": 140, "height": 100},
      {"booth_code": "A-02", "exhibition_id": 1, "price": 1500.0, "size": "20sqm", "status": "booked", "x": 210, "y": 50, "width": 140, "height": 100},
      {"booth_code": "B-10", "exhibition_id": 1, "price": 1000.0, "size": "12sqm", "status": "available", "x": 50, "y": 170, "width": 140, "height": 100},
      {"booth_code": "C-05", "exhibition_id": 1, "price": 2000.0, "size": "30sqm", "status": "available", "x": 380, "y": 50, "width": 210, "height": 220},
    ]) {
      await db.insert("booths", b);
    }

    // --- BOOTHS (EXPO 2) ---
    for (final b in [
      {"booth_code": "BK-01", "exhibition_id": 2, "price": 800.0, "size": "10sqm", "status": "available", "x": 60, "y": 60, "width": 120, "height": 90},
      {"booth_code": "BK-02", "exhibition_id": 2, "price": 1200.0, "size": "15sqm", "status": "available", "x": 200, "y": 60, "width": 120, "height": 90},
    ]) {
      await db.insert("booths", b);
    }
  }

  // =========================================================
  // GENERIC HELPERS
  // =========================================================
  Future<List<Map<String, dynamic>>> query(String table,
      {String? where, List<Object?>? whereArgs}) async {
    final db = await database;
    return db.query(table, where: where, whereArgs: whereArgs);
  }

  Future<int> insert(String table, Map<String, Object?> values) async {
    final db = await database;
    return db.insert(table, values);
  }

  Future<int> update(String table, Map<String, Object?> values,
      String where, List<Object?> whereArgs) async {
    final db = await database;
    return db.update(table, values, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(String table, String where, List<Object?> whereArgs) async {
    final db = await database;
    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  // =========================================================
  // EXHIBITIONS
  // =========================================================
  Future<List<Map<String, dynamic>>> getExhibitions() async {
    final db = await database;
    return db.query("exhibitions", orderBy: "id DESC");
  }

  Future<List<Map<String, dynamic>>> getExhibitionsByOrganizer(String username) async {
    final db = await database;
    final user = await db.query(
      "users",
      where: "username = ?",
      whereArgs: [username],
    );

    if (user.isEmpty) return [];

    final organizerId = user.first["id"] as int;

    return db.query(
      "exhibitions",
      where: "organizer_id = ?",
      whereArgs: [organizerId],
      orderBy: "id DESC",
    );
  }

  Future<int> saveExhibition(Map<String, Object?> data) async {
    final db = await database;

    if (data["id"] != null) {
      final id = data["id"] as int;
      final copy = Map<String, Object?>.from(data)..remove("id");
      return db.update("exhibitions", copy, where: "id = ?", whereArgs: [id]);
    }

    return db.insert("exhibitions", data);
  }

  // =========================================================
  // SEARCH & FILTER — EXHIBITIONS
  // =========================================================
  Future<List<Map<String, dynamic>>> searchExhibitions({
    String? keyword,
    String? startDate,
    String? endDate,
  }) async {
    final db = await database;

    final where = <String>[];
    final args = <Object?>[];

    // 🔎 Search by title / description
    if (keyword != null && keyword.isNotEmpty) {
      where.add("(title LIKE ? OR description LIKE ?)");
      args.add("%$keyword%");
      args.add("%$keyword%");
    }

    // 📅 Filter from date
    if (startDate != null && startDate.isNotEmpty) {
      where.add("start_date >= ?");
      args.add(startDate);
    }

    // 📅 Filter until date
    if (endDate != null && endDate.isNotEmpty) {
      where.add("end_date <= ?");
      args.add(endDate);
    }

    return db.query(
      "exhibitions",
      where: where.isEmpty ? null : where.join(" AND "),
      whereArgs: args,
      orderBy: "start_date ASC",
    );
  }

  // =========================================================
  // BOOTHS
  // =========================================================
  Future<List<Map<String, dynamic>>> getBoothsByExhibition(int id) async {
    final db = await database;
    return db.query("booths", where: "exhibition_id = ?", whereArgs: [id]);
  }

  Future<int> saveBooth(Map<String, Object?> booth) async {
    final db = await database;

    if (booth["id"] != null) {
      final id = booth["id"] as int;
      final copy = Map<String, Object?>.from(booth)..remove("id");
      return db.update("booths", copy, where: "id = ?", whereArgs: [id]);
    }

    return db.insert("booths", booth);
  }

  Future<int> updateBooth(int id, Map<String, Object?> data) async {
    final db = await database;

    // Ensure id is not stored twice
    final copy = Map<String, Object?>.from(data)..remove("id");

    return db.update(
      "booths",
      copy,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> deleteBooth(int id) async {
    final db = await database;
    return db.delete("booths", where: "id = ?", whereArgs: [id]);
  }

  // =========================================================
  // APPLICATIONS (ORGANIZER)
  // =========================================================
  Future<List<Map<String, dynamic>>> getApplicationsForOrganizer(
      String username) async {
    final db = await database;

    final user =
    await db.query("users", where: "username = ?", whereArgs: [username]);

    if (user.isEmpty) return [];

    final organizerId = user.first["id"] as int;

    final exhibitions = await db.query("exhibitions",
        where: "organizer_id = ?", whereArgs: [organizerId]);

    if (exhibitions.isEmpty) return [];

    final ids = exhibitions.map((e) => e["id"]).toList();
    final placeholders = List.filled(ids.length, "?").join(",");

    return db.rawQuery(
      "SELECT * FROM applications WHERE exhibition_id IN ($placeholders)",
      ids,
    );
  }

  Future<int> updateApplicationStatus(int appId, String status,
      {String? reason}) async {
    final db = await database;

    final app =
    await db.query("applications", where: "id = ?", whereArgs: [appId]);

    if (app.isEmpty) return 0;

    final boothId = app.first["booth_id"] as int?;

    final res = await db.update(
      "applications",
      {"status": status, "organizer_reason": reason},
      where: "id = ?",
      whereArgs: [appId],
    );

    if (res > 0 && status == "approved" && boothId != null) {
      await db.update("booths", {"status": "booked"},
          where: "id = ?", whereArgs: [boothId]);
    }

    return res;
  }

  // =========================================================
  // ADMIN — USER MANAGEMENT
  // =========================================================
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return db.query("users", orderBy: "role ASC, username ASC");
  }

  Future<int> updateUserRole(int id, String role) async {
    final db = await database;
    return db.update("users", {"role": role},
        where: "id = ?", whereArgs: [id]);
  }

  Future<int> deleteUser(int id) async {
    final db = await database;

    await db.delete("applications",
        where: "exhibitor_id = ?", whereArgs: [id]);

    return db.delete("users", where: "id = ?", whereArgs: [id]);
  }

  // =========================================================
  // DEV TOOL — RESET DB
  // =========================================================
  Future<void> resetDatabase() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }

    if (_dbPath != null) {
      final f = File(_dbPath!);
      if (await f.exists()) await f.delete();
    }

    await initAndSeed();
  }
}
