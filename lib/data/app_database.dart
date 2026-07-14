// lib/data/app_database.dart
// SceneFlow - SQLite persistence layer (sqflite)
//
// Thay thế cho việc chỉ giữ dữ liệu trong mock_data.dart / bộ nhớ RAM.
// Toàn bộ Project, Character, Location, Scene, Scene<->Character đều được
// lưu xuống một file .db thật trên máy, dữ liệu không mất khi tắt app.
//
// Ghi chú thiết kế:
// - Giữ nguyên kiểu id dạng TEXT (vd: 'loc-alley', 'sc-04') để tương thích
//   100% với các model & màn hình đã có sẵn của các thành viên khác trong
//   nhóm (Project, Character, Scene...), tránh phải sửa lại toàn bộ code cũ.
// - Bảng Acts trong đề bài gốc chưa có model riêng trong code hiện tại
//   (Project.acts đang là List<String> nhúng thẳng trong Project), nên ở
//   đây acts được lưu dưới dạng chuỗi JSON trong cột `acts` của bảng
//   projects để không phá vỡ code của module Project & Act Management.
// - Bảng schedule/shooting session KHÔNG được lưu trữ cố định, vì theo
//   đúng yêu cầu F4.1, lịch quay là kết quả "đề xuất" được tự động tính
//   toán (group by location) mỗi lần cần dùng, không phải dữ liệu tĩnh.

import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._internal();
  static final AppDatabase instance = AppDatabase._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cinex_sceneflow.db');

    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        // Bật ràng buộc khóa ngoại (mặc định sqflite tắt)
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE projects (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT,
            startDate TEXT,
            director TEXT,
            type TEXT,
            genre TEXT,
            status TEXT,
            progress INTEGER,
            thumbnailUrl TEXT,
            codeName TEXT,
            acts TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE characters (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            role TEXT,
            roleTitle TEXT,
            avatarUrl TEXT,
            psychologicalProfile TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE locations (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            scenesCovered TEXT,
            area TEXT,
            setting TEXT,
            timeOfDay TEXT,
            notes TEXT,
            imageUrl TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE scenes (
            id TEXT PRIMARY KEY,
            projectId TEXT NOT NULL,
            code TEXT,
            title TEXT,
            act TEXT,
            status TEXT,
            description TEXT,
            setting TEXT,
            timeOfDay TEXT,
            locationId TEXT,
            pages TEXT,
            estimatedHours REAL,
            actionDialogueText TEXT,
            FOREIGN KEY (projectId) REFERENCES projects (id) ON DELETE CASCADE,
            FOREIGN KEY (locationId) REFERENCES locations (id) ON DELETE SET NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE scene_characters (
            sceneId TEXT NOT NULL,
            characterId TEXT NOT NULL,
            PRIMARY KEY (sceneId, characterId),
            FOREIGN KEY (sceneId) REFERENCES scenes (id) ON DELETE CASCADE,
            FOREIGN KEY (characterId) REFERENCES characters (id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  // ── Generic helpers ──────────────────────────────────────────────────

  Future<bool> get isSeeded async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) AS c FROM projects');
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }

  // ── Locations ────────────────────────────────────────────────────────

  Future<List<Map<String, Object?>>> getAllLocations() async {
    final db = await database;
    return db.query('locations', orderBy: 'name ASC');
  }

  Future<void> upsertLocation(Map<String, Object?> row) async {
    final db = await database;
    await db.insert('locations', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteLocation(String id) async {
    final db = await database;
    await db.delete('locations', where: 'id = ?', whereArgs: [id]);
  }

  // ── Projects ─────────────────────────────────────────────────────────

  Future<List<Map<String, Object?>>> getAllProjects() async {
    final db = await database;
    return db.query('projects');
  }

  Future<void> upsertProject(Map<String, Object?> row) async {
    final db = await database;
    await db.insert('projects', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// F1.1: Xóa dự án. Nhờ `ON DELETE CASCADE` trên scenes.projectId và
  /// `PRAGMA foreign_keys = ON` ở trên, toàn bộ Scene thuộc dự án này sẽ
  /// tự động bị xóa theo ngay trong SQLite, không cần xóa tay từng bảng.
  Future<void> deleteProject(String id) async {
    final db = await database;
    await db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }

  // ── Characters ───────────────────────────────────────────────────────

  Future<List<Map<String, Object?>>> getAllCharacters() async {
    final db = await database;
    return db.query('characters');
  }

  Future<void> upsertCharacter(Map<String, Object?> row) async {
    final db = await database;
    await db.insert('characters', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ── Scenes ───────────────────────────────────────────────────────────

  Future<List<Map<String, Object?>>> getAllScenes() async {
    final db = await database;
    return db.query('scenes');
  }

  Future<void> upsertScene(Map<String, Object?> row, List<String> characterIds) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert('scenes', row, conflictAlgorithm: ConflictAlgorithm.replace);
      await txn.delete('scene_characters', where: 'sceneId = ?', whereArgs: [row['id']]);
      for (final charId in characterIds) {
        await txn.insert(
          'scene_characters',
          {'sceneId': row['id'], 'characterId': charId},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<String>> getCharacterIdsForScene(String sceneId) async {
    final db = await database;
    final rows = await db.query(
      'scene_characters',
      columns: ['characterId'],
      where: 'sceneId = ?',
      whereArgs: [sceneId],
    );
    return rows.map((r) => r['characterId'] as String).toList();
  }

  Future<Map<String, List<String>>> getAllSceneCharacterLinks() async {
    final db = await database;
    final rows = await db.query('scene_characters');
    final map = <String, List<String>>{};
    for (final r in rows) {
      final sceneId = r['sceneId'] as String;
      final charId = r['characterId'] as String;
      map.putIfAbsent(sceneId, () => []).add(charId);
    }
    return map;
  }

  // ── Seeding (first run only) ────────────────────────────────────────

  Future<void> seedIfEmpty({
    required List<Map<String, Object?>> projects,
    required List<Map<String, Object?>> characters,
    required List<Map<String, Object?>> locations,
    required List<Map<String, Object?>> scenes,
    required Map<String, List<String>> sceneCharacterLinks,
  }) async {
    if (await isSeeded) return;

    final db = await database;
    await db.transaction((txn) async {
      for (final p in projects) {
        await txn.insert('projects', p, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      for (final c in characters) {
        await txn.insert('characters', c, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      for (final l in locations) {
        await txn.insert('locations', l, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      for (final s in scenes) {
        await txn.insert('scenes', s, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      for (final entry in sceneCharacterLinks.entries) {
        for (final charId in entry.value) {
          await txn.insert(
            'scene_characters',
            {'sceneId': entry.key, 'characterId': charId},
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
  }

  /// Encode a List<String> as JSON text for storage in a TEXT column.
  static String encodeStringList(List<String> list) => jsonEncode(list);

  /// Decode a JSON text column back into a List<String>.
  static List<String> decodeStringList(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is List) return decoded.map((e) => e.toString()).toList();
    return [];
  }
}