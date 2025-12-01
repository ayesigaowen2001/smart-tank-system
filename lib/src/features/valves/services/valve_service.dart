import 'package:sqflite/sqflite.dart';
import '../../../shared/database/database_helper.dart';
import '../models/valve.dart';

class ValveService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertValve(Valve valve) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'valves',
      valve.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateValve(Valve valve) async {
    final db = await _dbHelper.database;
    return await db.update(
      'valves',
      valve.toMap(),
      where: 'id = ?',
      whereArgs: [valve.id],
    );
  }

  Future<int> deleteValve(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('valves', where: 'id = ?', whereArgs: [id]);
  }

  Future<Valve?> getValveById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'valves',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Valve.fromMap(result.first);
    }
    return null;
  }

  Future<Valve?> getValveByValveId(String valveId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'valves',
      where: 'valve_id = ?',
      whereArgs: [valveId],
    );
    if (result.isNotEmpty) {
      return Valve.fromMap(result.first);
    }
    return null;
  }

  Future<List<Valve>> getAllValves() async {
    final db = await _dbHelper.database;
    final result = await db.query('valves', orderBy: 'created_at DESC');
    return result.map((map) => Valve.fromMap(map)).toList();
  }

  Future<List<Valve>> getValvesByNodeId(int nodeId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'valves',
      where: 'node_id = ?',
      whereArgs: [nodeId],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Valve.fromMap(map)).toList();
  }

  Future<List<Valve>> getValvesByTankId(int tankId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'valves',
      where: 'tank_id = ?',
      whereArgs: [tankId],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Valve.fromMap(map)).toList();
  }

  Future<List<Valve>> getUnsyncedValves() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'valves',
      where: 'synced = ?',
      whereArgs: [0],
      orderBy: 'created_at ASC',
    );
    return result.map((map) => Valve.fromMap(map)).toList();
  }

  Future<int> markValveAsSynced(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'valves',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllValves() async {
    final db = await _dbHelper.database;
    return await db.delete('valves');
  }
}
