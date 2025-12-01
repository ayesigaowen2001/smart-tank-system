# Smart Tank System - Database & UI Documentation

## Overview

The Smart Tank System now features a fully integrated SQLite database for local data persistence with tabular UI pages for viewing and managing data.

## Database Architecture

### Tables Structure

#### 1. **NODES** (LoRa Slave Devices)

Represents LoRa slave nodes in the field with sensors and servo controls.

| Column        | Type      | Constraints               |
| ------------- | --------- | ------------------------- |
| id            | INTEGER   | PRIMARY KEY AUTOINCREMENT |
| node_id       | TEXT      | UNIQUE, NOT NULL          |
| battery_level | INTEGER   | CHECK (0-100)             |
| last_seen     | TIMESTAMP | NULL allowed              |
| location      | TEXT      | Optional                  |
| created_at    | TIMESTAMP | DEFAULT NOW()             |
| synced        | INTEGER   | 0=not synced, 1=synced    |

#### 2. **VALVES**

Physical valves controlled by nodes.

| Column      | Type      | Constraints               |
| ----------- | --------- | ------------------------- |
| id          | INTEGER   | PRIMARY KEY AUTOINCREMENT |
| valve_id    | TEXT      | UNIQUE, NOT NULL          |
| node_id     | INTEGER   | FK → nodes(id)            |
| name        | TEXT      | Optional                  |
| description | TEXT      | Optional                  |
| created_at  | TIMESTAMP | DEFAULT NOW()             |
| synced      | INTEGER   | 0=not synced, 1=synced    |

#### 3. **VALVE_STATES**

Historical records of valve state changes.

| Column    | Type      | Constraints               |
| --------- | --------- | ------------------------- |
| id        | INTEGER   | PRIMARY KEY AUTOINCREMENT |
| valve_id  | INTEGER   | FK → valves(id)           |
| state     | TEXT      | 'open' or 'closed'        |
| flow_rate | REAL      | >= 0                      |
| timestamp | TIMESTAMP | DEFAULT NOW()             |
| synced    | INTEGER   | 0=not synced, 1=synced    |

#### 4. **TELEMETRY**

Sensor data from nodes (humidity, temperature, battery, RSSI).

| Column      | Type      | Constraints                |
| ----------- | --------- | -------------------------- |
| id          | INTEGER   | PRIMARY KEY AUTOINCREMENT  |
| node_id     | INTEGER   | FK → nodes(id)             |
| humidity    | REAL      | >= 0                       |
| temperature | REAL      | Nullable                   |
| battery     | INTEGER   | CHECK (0-100)              |
| rssi        | INTEGER   | Nullable (signal strength) |
| timestamp   | TIMESTAMP | DEFAULT NOW()              |
| synced      | INTEGER   | 0=not synced, 1=synced     |

#### 5. **COMMANDS**

Commands sent from the Flutter app via MQTT to nodes.

| Column       | Type      | Constraints                   |
| ------------ | --------- | ----------------------------- |
| id           | INTEGER   | PRIMARY KEY AUTOINCREMENT     |
| valve_id     | INTEGER   | FK → valves(id)               |
| user_id      | INTEGER   | FK → users(id)                |
| command_type | TEXT      | 'open', 'close', 'set_flow'   |
| payload      | TEXT      | JSON string (optional)        |
| status       | TEXT      | 'sent', 'delivered', 'failed' |
| timestamp    | TIMESTAMP | DEFAULT NOW()                 |
| synced       | INTEGER   | 0=not synced, 1=synced        |

#### 6. **LOGS**

Application logs for debugging and audit trails.

| Column    | Type      | Constraints                |
| --------- | --------- | -------------------------- |
| id        | INTEGER   | PRIMARY KEY AUTOINCREMENT  |
| log_type  | TEXT      | NOT NULL                   |
| message   | TEXT      | NOT NULL                   |
| node_id   | INTEGER   | FK → nodes(id)             |
| valve_id  | INTEGER   | FK → valves(id)            |
| level     | TEXT      | 'info', 'warning', 'error' |
| timestamp | TIMESTAMP | DEFAULT NOW()              |
| synced    | INTEGER   | 0=not synced, 1=synced     |

#### 7. **TANKS**

Water tank monitoring and tracking.

| Column          | Type      | Constraints               |
| --------------- | --------- | ------------------------- |
| id              | INTEGER   | PRIMARY KEY AUTOINCREMENT |
| tank_id         | TEXT      | UNIQUE, NOT NULL          |
| name            | TEXT      | Optional                  |
| location        | TEXT      | Optional                  |
| capacity_liters | REAL      | Optional                  |
| current_level   | REAL      | Optional                  |
| last_updated    | TIMESTAMP | Optional                  |
| created_at      | TIMESTAMP | DEFAULT NOW()             |
| synced          | INTEGER   | 0=not synced, 1=synced    |

#### 8. **ALERTS**

System alerts for critical events.

| Column      | Type      | Constraints               |
| ----------- | --------- | ------------------------- |
| id          | INTEGER   | PRIMARY KEY AUTOINCREMENT |
| node_id     | INTEGER   | FK → nodes(id)            |
| alert_type  | TEXT      | NOT NULL                  |
| message     | TEXT      | NOT NULL                  |
| resolved    | INTEGER   | 0=open, 1=resolved        |
| created_at  | TIMESTAMP | DEFAULT NOW()             |
| resolved_at | TIMESTAMP | Nullable                  |
| synced      | INTEGER   | 0=not synced, 1=synced    |

## File Structure

```
lib/src/
├── shared/
│   ├── database/
│   │   └── database_helper.dart         # SQLite initialization & schema
│   ├── models/
│   │   ├── command.dart                 # Command model
│   │   └── telemetry.dart              # Telemetry model
│   └── services/
│       ├── command_service.dart        # Command DB operations
│       └── telemetry_service.dart      # Telemetry DB operations
│
├── features/
│   ├── valves/
│   │   ├── models/
│   │   │   ├── valve.dart              # Valve model
│   │   │   └── valve_state.dart        # Valve state model
│   │   ├── services/
│   │   │   ├── valve_service.dart      # Valve DB operations
│   │   │   └── valve_state_service.dart # Valve state DB operations
│   │   └── view/
│   │       └── valves_page.dart        # Tabular view of valves
│   │
│   ├── tanks/
│   │   ├── models/
│   │   │   └── tank.dart               # Tank model
│   │   ├── services/
│   │   │   └── tank_service.dart       # Tank DB operations
│   │   └── view/
│   │       └── tanks_page.dart         # Tabular view of tanks
│   │
│   ├── devices/
│   │   ├── models/
│   │   │   └── device_node.dart        # Device/Node model
│   │   ├── services/
│   │   │   └── device_service.dart     # Device DB operations
│   │   └── view/
│   │       └── devices_page.dart       # Tabular view of devices
│   │
│   └── logs/
│       ├── models/
│       │   └── log_entry.dart          # Log entry model
│       ├── services/
│       │   └── log_service.dart        # Log DB operations
│       └── view/
│           └── logs_page.dart          # Tabular view of logs
```

## Service Classes

### DatabaseHelper

Singleton class that manages database initialization and lifecycle.

```dart
// Initialize database (called in main.dart)
await DatabaseHelper().database;

// Close database
await DatabaseHelper().close();
```

### Data Services

#### ValveService

```dart
final service = ValveService();

// Create
await service.insertValve(valve);

// Read
final valve = await service.getValveById(id);
final valves = await service.getAllValves();
final valvesByNode = await service.getValvesByNodeId(nodeId);

// Update
await service.updateValve(valve);

// Delete
await service.deleteValve(id);

// Sync operations
final unsyncedValves = await service.getUnsyncedValves();
await service.markValveAsSynced(id);
```

#### TankService

```dart
final service = TankService();
await service.insertTank(tank);
final tanks = await service.getAllTanks();
// Similar CRUD operations as ValveService
```

#### DeviceService

```dart
final service = DeviceService();
await service.insertDevice(device);
final devices = await service.getAllDevices();
final count = await service.getDeviceCount();
// Similar CRUD operations as ValveService
```

#### LogService

```dart
final service = LogService();

// Write logs
await service.insertLog(logEntry);

// Read logs
final logs = await service.getAllLogs(limit: 1000);
final nodeLogs = await service.getLogsByNodeId(nodeId);
final errorLogs = await service.getLogsByLevel('error');

// Cleanup
await service.deleteOldLogs(DateTime.now().subtract(Duration(days: 30)));
```

#### CommandService

```dart
final service = CommandService();

// Send command
await service.insertCommand(command);

// Track status
final commands = await service.getCommandsByStatus('sent');
await service.updateCommandStatus(id, 'delivered');

// Unsynced operations
final unsyncedCommands = await service.getUnsyncedCommands();
await service.markCommandAsSynced(id);
```

#### ValveStateService

```dart
final service = ValveStateService();

// Record state change
await service.insertValveState(state);

// Get history
final history = await service.getStatesByValveId(valveId, limit: 100);
final latest = await service.getLatestStateForValve(valveId);
```

#### TelemetryService

```dart
final service = TelemetryService();

// Record telemetry
await service.insertTelemetry(telemetry);

// Retrieve data
final latest = await service.getLatestTelemetryForNode(nodeId);
final history = await service.getTelemetryByNodeId(nodeId, limit: 100);
```

## UI Pages

### Valves Page (`valves_page.dart`)

Displays all valves in a scrollable data table with columns:

- ID, Valve ID, Name, Description, Node ID, Created Date, Sync Status

Features:

- Horizontal scrolling for wide tables
- Refresh button to reload data
- Empty state handling
- Error handling with retry

### Tanks Page (`tanks_page.dart`)

Displays all tanks with monitoring data:

- ID, Tank ID, Name, Location, Capacity, Current Level, Fill %, Last Updated, Sync Status

Features:

- Fill percentage calculations
- Color-coded fill levels (Red: <50%, Orange: 50-80%, Green: >80%)
- Horizontal scrolling support

### Devices Page (`devices_page.dart`)

Displays all LoRa nodes/devices:

- ID, Node ID, Battery %, Battery Status, Location, Last Seen, Created Date, Sync Status

Features:

- Battery status indicator (Low <20% or Good)
- Color-coded battery warnings
- Last seen timestamp tracking

### Logs Page (`logs_page.dart`)

Displays application logs with filtering:

- ID, Timestamp, Level, Type, Message, Node ID, Valve ID, Sync Status

Features:

- Filter by log level (All, Info, Warning, Error)
- Color-coded severity levels
- Horizontal scrolling for long messages
- Latest logs displayed first

## Data Sync Pattern

Each entity has a `synced` field (0 or 1) to track synchronization with the server:

```dart
// Get unsynced data
final unsyncedValves = await valveService.getUnsyncedValves();

// Process and send to server...

// Mark as synced
await valveService.markValveAsSynced(id);
```

## Usage Examples

### Inserting Data

```dart
final valve = Valve(
  valveId: 'VALVE_001',
  nodeId: 1,
  name: 'North Gate',
  description: 'Main entrance valve',
);
await valveService.insertValve(valve);
```

### Recording a State Change

```dart
final state = ValveState(
  valveId: valveId,
  state: 'open',
  flowRate: 15.5,
);
await valveStateService.insertValveState(state);
```

### Logging Events

```dart
final log = LogEntry(
  logType: 'MQTT',
  message: 'Message received from node_001',
  nodeId: 1,
  level: 'info',
);
await logService.insertLog(log);
```

### Recording Telemetry

```dart
final telemetry = Telemetry(
  nodeId: 1,
  humidity: 65.5,
  temperature: 28.3,
  battery: 85,
  rssi: -75,
);
await telemetryService.insertTelemetry(telemetry);
```

## Database File Location

The SQLite database file (`smart_tank.db`) is stored in the device's application documents directory:

- Android: `/data/data/com.example.smart_tank_control/databases/smart_tank.db`
- iOS: `~/Documents/smart_tank.db` (in app sandbox)

## Best Practices

1. **Always await database operations** - SQLite operations are asynchronous
2. **Use services, not direct database access** - Encapsulate database logic in service classes
3. **Implement error handling** - Wrap database calls in try-catch blocks
4. **Batch operations** - For multiple inserts, use transactions
5. **Clean old data regularly** - Use cleanup methods to manage database size
6. **Track sync status** - Always mark records as synced after server confirms
7. **Indexes** - Created on foreign keys and synced field for faster queries

## Future Enhancements

- Implement database versioning and migrations
- Add full-text search for logs
- Implement offline-first synchronization
- Add data export/import functionality
- Implement encryption for sensitive data
- Add backup and restore mechanisms
