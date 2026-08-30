import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/focus_session.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('refocus_again.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE focus_sessions (
        id TEXT PRIMARY KEY,
        start_time INTEGER NOT NULL,
        planned_end_time INTEGER NOT NULL,
        duration_seconds INTEGER NOT NULL,
        status TEXT NOT NULL,
        is_strict INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        completed_at INTEGER,
        blocked_apps_json TEXT NOT NULL,
        label TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE blocked_apps (
        package_name TEXT PRIMARY KEY,
        app_name TEXT NOT NULL,
        is_selected INTEGER NOT NULL DEFAULT 1,
        added_at INTEGER NOT NULL
      )
    ''');
  }

  // Focus Session Operations
  Future<void> insertSession(FocusSessionModel session) async {
    final db = await database;
    await db.insert(
      'focus_sessions',
      {
        'id': session.id,
        'start_time': session.startTime.millisecondsSinceEpoch,
        'planned_end_time': session.plannedEndTime.millisecondsSinceEpoch,
        'duration_seconds': session.durationSeconds,
        'status': session.status.name,
        'is_strict': session.isStrictMode ? 1 : 0,
        'created_at': session.createdAt.millisecondsSinceEpoch,
        'completed_at': session.completedAt?.millisecondsSinceEpoch,
        'blocked_apps_json': jsonEncode(session.blockedApps),
        'label': session.label,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateSessionStatus(String id, SessionStatus status, {DateTime? completedAt}) async {
    final db = await database;
    final endedAt = completedAt ?? (status == SessionStatus.completed ? DateTime.now() : null);
    await db.update(
      'focus_sessions',
      {
        'status': status.name,
        'completed_at': endedAt?.millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<FocusSessionModel?> getActiveSession() async {
    final db = await database;
    final results = await db.query(
      'focus_sessions',
      where: 'status = ?',
      whereArgs: ['active'],
      orderBy: 'start_time DESC',
      limit: 1,
    );

    if (results.isEmpty) return null;
    return _mapSession(results.first);
  }

  Future<List<FocusSessionModel>> getAllSessions() async {
    final db = await database;
    final results = await db.query(
      'focus_sessions',
      orderBy: 'start_time DESC',
    );
    return results.map(_mapSession).toList();
  }

  Future<List<FocusSessionModel>> getCompletedSessionsToday() async {
    final db = await database;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final endOfDay = startOfDay + 86400000;

    final results = await db.query(
      'focus_sessions',
      where: 'status = ? AND start_time >= ? AND start_time < ?',
      whereArgs: ['completed', startOfDay, endOfDay],
      orderBy: 'start_time DESC',
    );
    return results.map(_mapSession).toList();
  }

  Future<int> getTodayTotalFocusMinutes() async {
    final sessions = await getCompletedSessionsToday();
    var totalSeconds = 0;
    for (final s in sessions) {
      totalSeconds += s.durationSeconds;
    }
    return totalSeconds ~/ 60;
  }

  Future<int> calculateCurrentStreakDays() async {
    final sessions = await getAllSessions();
    final completedSessions = sessions.where((s) => s.status == SessionStatus.completed).toList();
    if (completedSessions.isEmpty) return 0;

    final datesWithCompleted = <DateTime>{};
    for (final s in completedSessions) {
      final d = DateTime(s.startTime.year, s.startTime.month, s.startTime.day);
      datesWithCompleted.add(d);
    }

    final now = DateTime.now();
    var checkDate = DateTime(now.year, now.month, now.day);
    var streak = 0;

    // Check if user completed something today or yesterday
    if (!datesWithCompleted.contains(checkDate)) {
      // Check yesterday
      checkDate = checkDate.subtract(const Duration(days: 1));
      if (!datesWithCompleted.contains(checkDate)) {
        return 0;
      }
    }

    while (datesWithCompleted.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  // Blocked Apps Operations
  Future<List<Map<String, dynamic>>> getBlockedApps() async {
    final db = await database;
    return await db.query('blocked_apps', orderBy: 'app_name ASC');
  }

  Future<List<String>> getSelectedBlockedPackageNames() async {
    final db = await database;
    final results = await db.query(
      'blocked_apps',
      columns: ['package_name'],
      where: 'is_selected = ?',
      whereArgs: [1],
    );
    return results.map((row) => row['package_name'] as String).toList();
  }

  Future<void> setAppBlocked(String packageName, String appName, bool isSelected) async {
    final db = await database;
    await db.insert(
      'blocked_apps',
      {
        'package_name': packageName,
        'app_name': appName,
        'is_selected': isSelected ? 1 : 0,
        'added_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeBlockedApp(String packageName) async {
    final db = await database;
    await db.delete(
      'blocked_apps',
      where: 'package_name = ?',
      whereArgs: [packageName],
    );
  }

  FocusSessionModel _mapSession(Map<String, dynamic> map) {
    List<String> packages = [];
    try {
      final jsonStr = map['blocked_apps_json'] as String? ?? '[]';
      final decoded = jsonDecode(jsonStr);
      if (decoded is List) {
        packages = decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}

    return FocusSessionModel(
      id: map['id'] as String,
      startTime: DateTime.fromMillisecondsSinceEpoch(map['start_time'] as int),
      plannedEndTime: DateTime.fromMillisecondsSinceEpoch(map['planned_end_time'] as int),
      durationSeconds: map['duration_seconds'] as int,
      status: SessionStatus.fromString(map['status'] as String),
      isStrictMode: (map['is_strict'] as int? ?? 0) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      completedAt: map['completed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completed_at'] as int)
          : null,
      blockedApps: packages,
      label: map['label'] as String?,
    );
  }
}
