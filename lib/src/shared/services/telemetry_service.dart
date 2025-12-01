import '../database/database_helper.dart';
import '../../shared/models/telemetry.dart';

class TelemetryService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertTelemetry(Telemetry telemetry) async {
    final db = await _dbHelper.database;
    return await db.insert('telemetry', telemetry.toMap());
  }

  Future<List<Telemetry>> getTelemetryByNodeId(int nodeId,
      {int limit = 100}) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'telemetry',
      where: 'node_id = ?',
      whereArgs: [nodeId],
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return result.map((map) => Telemetry.fromMap(map)).toList();
  }

  Future<List<Telemetry>> getAllTelemetry({int limit = 500}) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'telemetry',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return result.map((map) => Telemetry.fromMap(map)).toList();
  }

  Future<Telemetry?> getLatestTelemetryForNode(int nodeId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'telemetry',
      where: 'node_id = ?',
      whereArgs: [nodeId],
      orderBy: 'timestamp DESC',
      limit: 1,
    );
    if (result.isNotEmpty) {
      return Telemetry.fromMap(result.first);
    }
    return null;
  }

  Future<int> deleteTelemetry(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('telemetry', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteOldTelemetry(DateTime before) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'telemetry',
      where: 'timestamp < ?',
      whereArgs: [before.toIso8601String()],
    );
  }

  Future<List<Telemetry>> getUnsyncedTelemetry({int limit = 500}) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'telemetry',
      where: 'synced = ?',
      whereArgs: [0],
      orderBy: 'timestamp ASC',
      limit: limit,
    );
    return result.map((map) => Telemetry.fromMap(map)).toList();
  }

  Future<int> markTelemetryAsSynced(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'telemetry',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
