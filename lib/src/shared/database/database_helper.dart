import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'smart_tank.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: _onOpen,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Nodes (LoRa slave devices) table
    await db.execute('''
      CREATE TABLE nodes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        node_id TEXT UNIQUE NOT NULL,
        battery_level INTEGER CHECK (battery_level BETWEEN 0 AND 100),
        last_seen TIMESTAMP,
        location TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Valves table
    await db.execute('''
      CREATE TABLE valves (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        valve_id TEXT UNIQUE NOT NULL,
        node_id INTEGER,
        tank_id INTEGER,
        name TEXT,
        description TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (node_id) REFERENCES nodes(id) ON DELETE CASCADE,
        FOREIGN KEY (tank_id) REFERENCES tanks(id) ON DELETE SET NULL
      )
    ''');

    // Valve States table (historical records)
    await db.execute('''
      CREATE TABLE valve_states (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        valve_id INTEGER NOT NULL,
        state TEXT NOT NULL CHECK (state IN ('open', 'closed')),
        flow_rate REAL CHECK (flow_rate >= 0),
        timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (valve_id) REFERENCES valves(id) ON DELETE CASCADE
      )
    ''');

    // Telemetry (sensor data from nodes) table
    await db.execute('''
      CREATE TABLE telemetry (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        node_id INTEGER NOT NULL,
        humidity REAL CHECK (humidity >= 0),
        temperature REAL,
        battery INTEGER CHECK (battery BETWEEN 0 AND 100),
        rssi INTEGER,
        timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (node_id) REFERENCES nodes(id) ON DELETE CASCADE
      )
    ''');

    // Commands table (sent from app)
    await db.execute('''
      CREATE TABLE commands (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        valve_id INTEGER,
        user_id INTEGER,
        command_type TEXT NOT NULL CHECK (command_type IN ('open', 'close', 'set_flow')),
        payload TEXT,
        status TEXT DEFAULT 'sent' CHECK (status IN ('sent', 'delivered', 'failed')),
        timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (valve_id) REFERENCES valves(id) ON DELETE SET NULL
      )
    ''');

    // Logs table
    await db.execute('''
      CREATE TABLE logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        log_type TEXT NOT NULL,
        message TEXT NOT NULL,
        node_id INTEGER,
        valve_id INTEGER,
        level TEXT DEFAULT 'info' CHECK (level IN ('info', 'warning', 'error')),
        timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (node_id) REFERENCES nodes(id) ON DELETE CASCADE,
        FOREIGN KEY (valve_id) REFERENCES valves(id) ON DELETE CASCADE
      )
    ''');

    // Tanks table (optional, for water tank monitoring)
    await db.execute('''
      CREATE TABLE tanks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tank_id TEXT UNIQUE NOT NULL,
        name TEXT,
        location TEXT,
        capacity_liters REAL,
        current_level REAL,
        last_updated TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Alerts table
    await db.execute('''
      CREATE TABLE alerts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        node_id INTEGER,
        alert_type TEXT NOT NULL,
        message TEXT NOT NULL,
        resolved INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        resolved_at TIMESTAMP,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (node_id) REFERENCES nodes(id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for faster queries
    await db.execute('CREATE INDEX idx_valve_node ON valves(node_id)');
    await db.execute('CREATE INDEX idx_valve_tank_id ON valves(tank_id)');
    await db.execute('CREATE INDEX idx_state_valve ON valve_states(valve_id)');
    await db.execute('CREATE INDEX idx_telemetry_node ON telemetry(node_id)');
    await db.execute('CREATE INDEX idx_command_valve ON commands(valve_id)');
    await db.execute('CREATE INDEX idx_logs_node ON logs(node_id)');
    await db.execute('CREATE INDEX idx_alerts_node ON alerts(node_id)');
    await db.execute('CREATE INDEX idx_synced_status ON valves(synced)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Simple migration: add `tank_id` column to `valves` table in v2
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE valves ADD COLUMN tank_id INTEGER');
      } catch (e) {
        // If column already exists or ALTER fails, ignore to keep migration safe
      }

      try {
        await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_valve_tank_id ON valves(tank_id)');
      } catch (e) {
        // ignore
      }
    }
  }

  Future<void> _onOpen(Database db) async {
    // Ensure `tank_id` column exists on valves table (covers edge cases where DB was
    // created before this column was introduced but already at same DB version).
    try {
      final info = await db.rawQuery("PRAGMA table_info(valves)");
      final hasTankId = info.any((row) => row['name'] == 'tank_id');
      if (!hasTankId) {
        await db.execute('ALTER TABLE valves ADD COLUMN tank_id INTEGER');
        await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_valve_tank_id ON valves(tank_id)');
      }
    } catch (e) {
      // ignore - keep DB usable
    }
  }

  Future<void> close() async {
    _database?.close();
    _database = null;
  }
}
