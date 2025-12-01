import 'package:sqflite/sqflite.dart';
import '../../../shared/database/database_helper.dart';
import '../models/device_node.dart';

class DeviceService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertDevice(DeviceNode device) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'nodes',
      device.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateDevice(DeviceNode device) async {
    final db = await _dbHelper.database;
    return await db.update(
      'nodes',
      device.toMap(),
      where: 'id = ?',
      whereArgs: [device.id],
    );
  }

  Future<int> deleteDevice(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('nodes', where: 'id = ?', whereArgs: [id]);
  }

  Future<DeviceNode?> getDeviceById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'nodes',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return DeviceNode.fromMap(result.first);
    }
    return null;
  }

  Future<DeviceNode?> getDeviceByNodeId(String nodeId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'nodes',
      where: 'node_id = ?',
      whereArgs: [nodeId],
    );
    if (result.isNotEmpty) {
      return DeviceNode.fromMap(result.first);
    }
    return null;
  }

  Future<List<DeviceNode>> getAllDevices() async {
    final db = await _dbHelper.database;
    final result = await db.query('nodes', orderBy: 'created_at DESC');
    return result.map((map) => DeviceNode.fromMap(map)).toList();
  }

  Future<List<DeviceNode>> getUnsyncedDevices() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'nodes',
      where: 'synced = ?',
      whereArgs: [0],
      orderBy: 'created_at ASC',
    );
    return result.map((map) => DeviceNode.fromMap(map)).toList();
  }

  Future<int> markDeviceAsSynced(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'nodes',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllDevices() async {
    final db = await _dbHelper.database;
    return await db.delete('nodes');
  }

  Future<int> getDeviceCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM nodes');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
