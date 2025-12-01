import '../../../shared/database/database_helper.dart';
import '../models/valve_state.dart';

class ValveStateService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertValveState(ValveState state) async {
    final db = await _dbHelper.database;
    return await db.insert('valve_states', state.toMap());
  }

  Future<List<ValveState>> getStatesByValveId(int valveId,
      {int limit = 100}) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'valve_states',
      where: 'valve_id = ?',
      whereArgs: [valveId],
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return result.map((map) => ValveState.fromMap(map)).toList();
  }

  Future<List<ValveState>> getAllValveStates({int limit = 500}) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'valve_states',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return result.map((map) => ValveState.fromMap(map)).toList();
  }

  Future<ValveState?> getLatestStateForValve(int valveId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'valve_states',
      where: 'valve_id = ?',
      whereArgs: [valveId],
      orderBy: 'timestamp DESC',
      limit: 1,
    );
    if (result.isNotEmpty) {
      return ValveState.fromMap(result.first);
    }
    return null;
  }

  Future<int> deleteValveState(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('valve_states', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteOldValveStates(DateTime before) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'valve_states',
      where: 'timestamp < ?',
      whereArgs: [before.toIso8601String()],
    );
  }

  Future<List<ValveState>> getUnsyncedValveStates({int limit = 500}) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'valve_states',
      where: 'synced = ?',
      whereArgs: [0],
      orderBy: 'timestamp ASC',
      limit: limit,
    );
    return result.map((map) => ValveState.fromMap(map)).toList();
  }

  Future<int> markValveStateAsSynced(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'valve_states',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
