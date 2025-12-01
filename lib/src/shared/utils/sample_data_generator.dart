import 'dart:math';
import '../../features/valves/models/valve.dart';
import '../../features/valves/models/valve_state.dart';
import '../../features/tanks/models/tank.dart';
import '../../features/devices/models/device_node.dart';
import '../../features/logs/models/log_entry.dart';
import '../../shared/models/telemetry.dart';
import '../../shared/models/command.dart';
import '../../features/valves/services/valve_service.dart';
import '../../features/valves/services/valve_state_service.dart';
import '../../features/tanks/services/tank_service.dart';
import '../../features/devices/services/device_service.dart';
import '../../features/logs/services/log_service.dart';
import '../../shared/services/telemetry_service.dart';
import '../../shared/services/command_service.dart';

/// Sample Data Generator for Testing
///
/// This utility class generates sample data for all entities to test
/// the database and UI pages.
class SampleDataGenerator {
  static final Random _random = Random();

  /// Generate sample devices/nodes
  static Future<List<DeviceNode>> generateSampleDevices({int count = 3}) async {
    final service = DeviceService();
    final devices = <DeviceNode>[];

    for (int i = 1; i <= count; i++) {
      final device = DeviceNode(
        nodeId: 'NODE_00$i',
        batteryLevel: 50 + _random.nextInt(50),
        lastSeen: DateTime.now(),
        location: 'Field Zone $i',
      );
      final id = await service.insertDevice(device);
      devices.add(device.copyWith(id: id));
    }

    return devices;
  }

  /// Generate sample valves
  static Future<List<Valve>> generateSampleValves(
      {int count = 5, List<Tank>? tanks}) async {
    final service = ValveService();
    final valves = <Valve>[];

    for (int i = 1; i <= count; i++) {
      final assignedTankId = (tanks != null && tanks.isNotEmpty)
          ? tanks[_random.nextInt(tanks.length)].id
          : null;

      final valve = Valve(
        valveId: 'VALVE_00$i',
        nodeId: (i % 3) + 1, // Distribute across 3 nodes
        tankId: assignedTankId,
        name: 'Valve $i',
        description: 'Irrigation valve in sector ${i % 4}',
      );
      final id = await service.insertValve(valve);
      valves.add(valve.copyWith(id: id));
    }

    return valves;
  }

  /// Generate sample valve states (historical records)
  static Future<void> generateSampleValveStates(List<Valve> valves) async {
    final service = ValveStateService();

    for (final valve in valves) {
      if (valve.id != null) {
        // Create multiple state changes over time
        for (int i = 0; i < 10; i++) {
          final state = ValveState(
            valveId: valve.id!,
            state: _random.nextBool() ? 'open' : 'closed',
            flowRate: _random.nextDouble() * 50,
            timestamp: DateTime.now().subtract(Duration(minutes: 10 * i)),
          );
          await service.insertValveState(state);
        }
      }
    }
  }

  /// Generate sample tanks
  static Future<List<Tank>> generateSampleTanks({int count = 2}) async {
    final service = TankService();
    final tanks = <Tank>[];

    for (int i = 1; i <= count; i++) {
      final capacity = 5000.0 + (i * 1000);
      final currentLevel = _random.nextDouble() * capacity;
      final tank = Tank(
        tankId: 'TANK_00$i',
        name: 'Water Tank $i',
        location: 'Zone $i',
        capacityLiters: capacity,
        currentLevel: currentLevel,
        lastUpdated: DateTime.now(),
      );
      final id = await service.insertTank(tank);
      tanks.add(tank.copyWith(id: id));
    }

    return tanks;
  }

  /// Generate sample telemetry data
  static Future<void> generateSampleTelemetry() async {
    final service = TelemetryService();

    for (int nodeId = 1; nodeId <= 3; nodeId++) {
      // Generate multiple telemetry readings
      for (int i = 0; i < 20; i++) {
        final telemetry = Telemetry(
          nodeId: nodeId,
          humidity: 40 + _random.nextDouble() * 40, // 40-80%
          temperature: 20 + _random.nextDouble() * 15, // 20-35°C
          battery: 30 + _random.nextInt(70), // 30-100%
          rssi: -100 + _random.nextInt(40), // -100 to -60 dBm
          timestamp: DateTime.now().subtract(Duration(minutes: 5 * i)),
        );
        await service.insertTelemetry(telemetry);
      }
    }
  }

  /// Generate sample logs
  static Future<void> generateSampleLogs() async {
    final service = LogService();
    final logTypes = ['MQTT', 'VALVE_OP', 'SENSOR', 'SYNC', 'ERROR'];
    final messages = [
      'Connection established',
      'Message received',
      'Valve opened successfully',
      'Sensor reading: 65% humidity',
      'Data synced to server',
      'Low battery warning',
      'Connection timeout',
      'Invalid command received',
    ];

    for (int i = 0; i < 50; i++) {
      final level = _random.nextInt(100) < 70
          ? 'info'
          : (_random.nextBool() ? 'warning' : 'error');
      final log = LogEntry(
        logType: logTypes[_random.nextInt(logTypes.length)],
        message: messages[_random.nextInt(messages.length)],
        nodeId: _random.nextInt(3) + 1,
        valveId: _random.nextBool() ? _random.nextInt(5) + 1 : null,
        level: level,
        timestamp: DateTime.now().subtract(Duration(minutes: i * 2)),
      );
      await service.insertLog(log);
    }
  }

  /// Generate sample commands
  static Future<void> generateSampleCommands(List<Valve> valves) async {
    final service = CommandService();
    final commandTypes = ['open', 'close', 'set_flow'];

    for (int i = 0; i < 20; i++) {
      final command = Command(
        valveId: valves[_random.nextInt(valves.length)].id,
        commandType: commandTypes[_random.nextInt(commandTypes.length)],
        status: _random.nextInt(100) < 80 ? 'delivered' : 'sent',
        payload:
            i % 3 == 0 ? '{"flow_rate": ${_random.nextDouble() * 50}}' : null,
        timestamp: DateTime.now().subtract(Duration(minutes: i * 3)),
      );
      await service.insertCommand(command);
    }
  }

  /// Generate ALL sample data
  /// Call this function in development/testing to populate the database
  static Future<void> generateAllSampleData() async {
    print('🔄 Generating sample data...');

    try {
      // Generate in order of dependencies
      print('📱 Generating devices...');
      final devices = await generateSampleDevices(count: 3);

      print('🏘️ Generating tanks...');
      final tanks = await generateSampleTanks(count: 2);

      print('🚰 Generating valves...');
      final valves = await generateSampleValves(count: 5, tanks: tanks);

      print('💧 Generating valve states...');
      await generateSampleValveStates(valves);

      print('📊 Generating telemetry...');
      await generateSampleTelemetry();

      print('📝 Generating logs...');
      await generateSampleLogs();

      print('📤 Generating commands...');
      await generateSampleCommands(valves);

      print('✅ Sample data generation completed successfully!');
      print('📊 Generated:');
      print('   - ${devices.length} devices');
      print('   - ${valves.length} valves');
      print('   - ${valves.length * 10} valve states');
      print('   - 2 tanks');
      print('   - 60 telemetry readings');
      print('   - 50 log entries');
      print('   - 20 commands');
    } catch (e) {
      print('❌ Error generating sample data: $e');
      rethrow;
    }
  }

  /// Clear all sample data from database
  static Future<void> clearAllData() async {
    print('🗑️ Clearing all data...');

    try {
      await DeviceService().deleteAllDevices();
      await ValveService().deleteAllValves();
      await TankService().deleteAllTanks();
      await LogService().deleteAllLogs();
      print('✅ All data cleared!');
    } catch (e) {
      print('❌ Error clearing data: $e');
      rethrow;
    }
  }
}

/// USAGE in your app:
///
/// In main.dart or a debug screen:
///
/// ```dart
/// // Generate sample data for testing
/// await SampleDataGenerator.generateAllSampleData();
///
/// // Clear sample data
/// await SampleDataGenerator.clearAllData();
/// ```
