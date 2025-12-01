import '../database/database_helper.dart';
import '../../shared/models/command.dart';

class CommandService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertCommand(Command command) async {
    final db = await _dbHelper.database;
    return await db.insert('commands', command.toMap());
  }

  Future<int> updateCommand(Command command) async {
    final db = await _dbHelper.database;
    return await db.update(
      'commands',
      command.toMap(),
      where: 'id = ?',
      whereArgs: [command.id],
    );
  }

  Future<int> deleteCommand(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('commands', where: 'id = ?', whereArgs: [id]);
  }

  Future<Command?> getCommandById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'commands',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Command.fromMap(result.first);
    }
    return null;
  }

  Future<List<Command>> getAllCommands({int limit = 500}) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'commands',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return result.map((map) => Command.fromMap(map)).toList();
  }

  Future<List<Command>> getCommandsByValveId(int valveId,
      {int limit = 100}) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'commands',
      where: 'valve_id = ?',
      whereArgs: [valveId],
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return result.map((map) => Command.fromMap(map)).toList();
  }

  Future<List<Command>> getCommandsByStatus(String status,
      {int limit = 500}) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'commands',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return result.map((map) => Command.fromMap(map)).toList();
  }

  Future<List<Command>> getUnsyncedCommands({int limit = 500}) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'commands',
      where: 'synced = ?',
      whereArgs: [0],
      orderBy: 'timestamp ASC',
      limit: limit,
    );
    return result.map((map) => Command.fromMap(map)).toList();
  }

  Future<int> markCommandAsSynced(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'commands',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateCommandStatus(int id, String status) async {
    final db = await _dbHelper.database;
    return await db.update(
      'commands',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteOldCommands(DateTime before) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'commands',
      where: 'timestamp < ?',
      whereArgs: [before.toIso8601String()],
    );
  }
}
