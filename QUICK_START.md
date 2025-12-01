# Quick Start Guide - Database & Tabular Views

## Getting Started

### 1. Build the App

```bash
cd d:\smartTank\smart-tank-system
flutter pub get
flutter run
```

### 2. Test with Sample Data

Add this code to your debug menu or a test button in the dashboard:

```dart
import 'package:smart_tank_control/src/shared/utils/sample_data_generator.dart';

// Generate sample data for testing
onPressed: () async {
  await SampleDataGenerator.generateAllSampleData();
  // App will auto-reload and show data in tables
}
```

### 3. Navigate to Data Pages

From the Dashboard, open the Navigation Drawer and click:

- **Tanks** - View all tanks with fill levels
- **Valves** - View all valves and their states
- **Devices** - View LoRa nodes with battery status
- **Logs** - View system logs with filtering

## Project Structure Summary

```
✅ Database Layer (Local SQLite)
   ├── DatabaseHelper (singleton for DB management)
   ├── 8 Tables (Nodes, Valves, Tanks, etc.)
   ├── Indexes on foreign keys & synced field
   └── Auto-migrations support

✅ Service Layer (Data Operations)
   ├── ValveService - CRUD for valves
   ├── TankService - CRUD for tanks
   ├── DeviceService - CRUD for devices/nodes
   ├── LogService - CRUD for logs with filtering
   ├── CommandService - CRUD for commands
   ├── TelemetryService - CRUD for sensor data
   └── ValveStateService - Historical valve records

✅ Data Models
   ├── Valve, Tank, DeviceNode, LogEntry
   ├── ValveState, Telemetry, Command
   └── All with toMap() and fromMap() serialization

✅ UI Pages (Tabular, Scrollable)
   ├── ValvesPage - 7 columns with sync status
   ├── TanksPage - 9 columns with fill% calculation
   ├── DevicesPage - 8 columns with battery indicators
   ├── LogsPage - 8 columns with level filtering
   └── All with error handling & empty states

✅ Utilities
   └── SampleDataGenerator - Generate test data
```

## Key Features

### Tabular Display

- **Horizontal scrolling** for wide tables
- **DataTable widget** for consistent styling
- **Empty state handling** with icons
- **Error states** with retry buttons
- **Refresh buttons** on AppBar and FAB

### Data Management

- **Local persistence** with SQLite
- **Sync tracking** - tracks synced vs unsynced records
- **Historical records** - valve state history, telemetry logs
- **Time-based filtering** - cleanup old data
- **Foreign key constraints** - referential integrity

### Search & Filter

- **Logs**: Filter by level (info/warning/error)
- **Devices**: Sort by battery status
- **Tanks**: Calculate and display fill percentages
- **Valves**: View by node or all

## Database Files Location

- **Android**: `/data/data/com.example.smart_tank_control/databases/smart_tank.db`
- **iOS**: `~/Documents/smart_tank.db`
- **Development**: Check DatabaseHelper.dart for path

## Common Tasks

### Add a New Valve to Database

```dart
import 'package:smart_tank_control/src/features/valves/models/valve.dart';
import 'package:smart_tank_control/src/features/valves/services/valve_service.dart';

final valve = Valve(
  valveId: 'VALVE_NEW_001',
  nodeId: 1,
  name: 'New Valve',
  description: 'Test valve',
);

final service = ValveService();
final id = await service.insertValve(valve);
print('Valve inserted with ID: $id');
```

### Record a State Change

```dart
import 'package:smart_tank_control/src/features/valves/models/valve_state.dart';
import 'package:smart_tank_control/src/features/valves/services/valve_state_service.dart';

final state = ValveState(
  valveId: valveId,
  state: 'open',
  flowRate: 15.5,
);

await ValveStateService().insertValveState(state);
```

### Log an Event

```dart
import 'package:smart_tank_control/src/features/logs/models/log_entry.dart';
import 'package:smart_tank_control/src/features/logs/services/log_service.dart';

await LogService().insertLog(
  LogEntry(
    logType: 'MQTT',
    message: 'Connection established',
    nodeId: 1,
    level: 'info',
  ),
);
```

### Get Unsynced Data (for Server Sync)

```dart
// Get all unsync data
final unsynced = await ValveService().getUnsyncedValves();

// Send to server...

// Mark as synced
await ValveService().markValveAsSynced(id);
```

## Data Flow

```
User Action (e.g., tap valve)
    ↓
DashboardController
    ↓
Send MQTT Command → Record in CommandService
    ↓
Receive MQTT Update
    ↓
Update Valve State → ValveStateService
    ↓
Log Event → LogService
    ↓
Mark for Sync → synced = 0
    ↓
Background Sync Job
    ↓
Upload to Server → Mark synced = 1
```

## Integration with MQTT

The database works alongside DashboardController:

```dart
// In DashboardController:
_dashboardController.onValveStatusUpdate.listen((valve) {
  // Record to database
  ValveStateService().insertValveState(
    ValveState(valveId: valve.id, state: valve.isOpen ? 'open' : 'closed'),
  );
});

// Send command
_dashboardController.sendCommand('VALVE_001', 'open');
// Auto-logged in CommandService
```

## Testing Workflow

1. **Start app** → Dashboard loads
2. **Generate sample data** → See populated tables
3. **Navigate to Tanks/Valves/Devices/Logs** → Browse tabular data
4. **Test filters** → Logs page has level filter
5. **Refresh data** → Tap refresh button, data reloads
6. **Clear data** → Use SampleDataGenerator.clearAllData()

## Troubleshooting

### "Database file not found"

- Ensure `DatabaseHelper().database` is called in main() before any services
- Check database initialization order in main.dart

### "Table already exists"

- This is normal - SQLite ignores duplicates
- Database schema created once on first run

### "No data in tables"

- Use `SampleDataGenerator.generateAllSampleData()` to populate
- Or implement MQTT sync to populate from broker

### "Slow table loads"

- Add pagination (implement lazy loading)
- Limit query results: `getAllLogs(limit: 100)`
- Use indexes (already created on foreign keys)

## Next Steps

1. ✅ Verify app builds: `flutter run`
2. ✅ Generate sample data for testing
3. ✅ Navigate Drawer → Test all tabular pages
4. ✅ Implement MQTT → Command & Telemetry sync
5. ✅ Build server API → Implement sync endpoints
6. ✅ Add authentication → Persist user context
7. ✅ Implement export → Export logs/data as CSV

## Support

For issues or questions, refer to:

- `DATABASE_DOCUMENTATION.md` - Full schema reference
- `SampleDataGenerator` class - Example data insertion
- Service classes - CRUD operation examples
- Model classes - Data structure definitions

Happy testing! 🚀
