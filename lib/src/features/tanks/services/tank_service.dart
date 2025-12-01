import 'package:sqflite/sqflite.dart';
import '../../../shared/database/database_helper.dart';
import '../models/tank.dart';

class TankService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertTank(Tank tank) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'tanks',
      tank.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateTank(Tank tank) async {
    final db = await _dbHelper.database;
    return await db.update(
      'tanks',
      tank.toMap(),
      where: 'id = ?',
      whereArgs: [tank.id],
    );
  }

  Future<int> deleteTank(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('tanks', where: 'id = ?', whereArgs: [id]);
  }

  Future<Tank?> getTankById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'tanks',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Tank.fromMap(result.first);
    }
    return null;
  }

  Future<Tank?> getTankByTankId(String tankId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'tanks',
      where: 'tank_id = ?',
      whereArgs: [tankId],
    );
    if (result.isNotEmpty) {
      return Tank.fromMap(result.first);
    }
    return null;
  }

  Future<List<Tank>> getAllTanks() async {
    final db = await _dbHelper.database;
    final result = await db.query('tanks', orderBy: 'created_at DESC');
    return result.map((map) => Tank.fromMap(map)).toList();
  }

  Future<List<Tank>> getUnsyncedTanks() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'tanks',
      where: 'synced = ?',
      whereArgs: [0],
      orderBy: 'created_at ASC',
    );
    return result.map((map) => Tank.fromMap(map)).toList();
  }

  Future<int> markTankAsSynced(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'tanks',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllTanks() async {
    final db = await _dbHelper.database;
    return await db.delete('tanks');
  }
}
