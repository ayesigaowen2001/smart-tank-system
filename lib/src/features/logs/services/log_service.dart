import 'package:sqflite/sqflite.dart';
import '../../../shared/database/database_helper.dart';
import '../models/log_entry.dart';

class LogService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertLog(LogEntry log) async {
    final db = await _dbHelper.database;
    return await db.insert('logs', log.toMap());
  }

  Future<int> deleteLog(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('logs', where: 'id = ?', whereArgs: [id]);
  }

  Future<LogEntry?> getLogById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'logs',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return LogEntry.fromMap(result.first);
    }
    return null;
  }

  Future<List<LogEntry>> getAllLogs({int limit = 1000}) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'logs',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return result.map((map) => LogEntry.fromMap(map)).toList();
  }

  Future<List<LogEntry>> getLogsByNodeId(int nodeId, {int limit = 500}) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'logs',
      where: 'node_id = ?',
      whereArgs: [nodeId],
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return result.map((map) => LogEntry.fromMap(map)).toList();
  }

  Future<List<LogEntry>> getLogsByValveId(int valveId,
      {int limit = 500}) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'logs',
      where: 'valve_id = ?',
      whereArgs: [valveId],
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return result.map((map) => LogEntry.fromMap(map)).toList();
  }

  Future<List<LogEntry>> getLogsByLevel(String level, {int limit = 500}) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'logs',
      where: 'level = ?',
      whereArgs: [level],
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return result.map((map) => LogEntry.fromMap(map)).toList();
  }

  Future<List<LogEntry>> getUnsyncedLogs({int limit = 500}) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'logs',
      where: 'synced = ?',
      whereArgs: [0],
      orderBy: 'timestamp ASC',
      limit: limit,
    );
    return result.map((map) => LogEntry.fromMap(map)).toList();
  }

  Future<int> markLogAsSynced(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'logs',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteOldLogs(DateTime before) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'logs',
      where: 'timestamp < ?',
      whereArgs: [before.toIso8601String()],
    );
  }

  Future<int> getLogCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM logs');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> deleteAllLogs() async {
    final db = await _dbHelper.database;
    return await db.delete('logs');
  }
}
