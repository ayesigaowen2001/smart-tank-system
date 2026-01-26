import 'dart:math';
import 'package:flutter/material.dart';
import '../controller/dashboard_controller.dart';
import '../widgets/valve_card.dart';
import '../../tanks/view/tanks_page.dart';
import '../../valves/view/valves_page.dart';
import '../../devices/view/devices_page.dart';
import '../../logs/view/logs_page.dart';
import '../../../settings/settings_view.dart';

// Services & models used by the dashboard controls
import '../../tanks/services/tank_service.dart';
import '../../tanks/models/tank.dart';
import '../../valves/services/valve_service.dart';
import '../../valves/models/valve.dart' as db_valve;
import '../../valves/services/valve_state_service.dart';
import '../../valves/models/valve_state.dart';
import '../../../shared/services/command_service.dart';
import '../../../shared/models/command.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late DashboardController _dashboardController;
  final TankService _tankService = TankService();
  final ValveService _valveService = ValveService();
  final ValveStateService _valveStateService = ValveStateService();
  final CommandService _commandService = CommandService();

  List<Tank> _tanks = [];
  List<db_valve.Valve> _dbValves = [];
  // Selected valve ids for group control
  final Set<int> _selectedValveIds = <int>{};
  double _groupFlowValue = 0.0;

  @override
  void initState() {
    super.initState();
    _dashboardController = DashboardController();
    _dashboardController.addListener(_onControllerChanged);
    _connectToBroker();
    _loadTanksAndValves();
  }

  Future<void> _loadTanksAndValves() async {
    final tanks = await _tankService.getAllTanks();
    final valves = await _valveService.getAllValves();
    setState(() {
      _tanks = tanks;
      _dbValves = valves;
    });
  }

  double _computeSelectedAverage() {
    if (_selectedValveIds.isEmpty) return 0.0;
    final list = _selectedValveIds
        .map((id) => _dashboardController.valves[id]?.flowRate ?? 0.0)
        .toList();
    if (list.isEmpty) return 0.0;
    final sum = list.reduce((a, b) => a + b);
    return sum / list.length;
  }

  Future<void> _applyFlowToValve(db_valve.Valve v, double flow) async {
    if (v.id == null) return;
    // Create command record
    final cmd = Command(
      valveId: v.id,
      commandType: 'set_flow',
      payload: '{"flow_rate": ${flow.toStringAsFixed(0)}}',
    );
    await _commandService.insertCommand(cmd);

    // Insert valve state record
    final vs = ValveState(
      valveId: v.id!,
      state: flow > 0 ? 'open' : 'closed',
      flowRate: flow,
    );
    await _valveStateService.insertValveState(vs);

    // Also request reload of UI state
    _loadTanksAndValves();
  }

  Future<void> _applyFlowToSelected(double flow) async {
    final ids = _selectedValveIds.toList();
    for (final id in ids) {
      final v = _dbValves.firstWhere((e) => e.id == id,
          orElse: () => db_valve.Valve(valveId: 'unknown', nodeId: 0));
      if (v.id != null) await _applyFlowToValve(v, flow);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Applied ${flow.toStringAsFixed(0)}% to ${ids.length} valves')));
  }

  Future<void> _applyFlowToAllValves(double flow) async {
    for (final v in _dbValves) {
      if (v.id != null) await _applyFlowToValve(v, flow);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Applied ${flow.toStringAsFixed(0)}% to all valves')));
  }

  void _connectToBroker() {
    _dashboardController.connect();
  }

  void _onControllerChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _dashboardController.removeListener(_onControllerChanged);
    _dashboardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Tank Dashboard'),
        elevation: 2,
        // Badge showing number of connected valves
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Row(
                children: [
                  Tooltip(
                    message: 'MQTT: ${_dashboardController.connectionStatus}',
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _dashboardController.isConnected
                            ? Colors.green
                            : Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _dashboardController.isConnected ? 'MQTT' : 'Offline',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  // Connected valves badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.water_drop,
                            size: 16, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          '${_dashboardController.valves.values.where((v) => v.isConnected).length}',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        // Add a navigation drawer icon automatically
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('SMART TANK SYSTEM',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('LoRa Valve Dashboard',
                        style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text('Dashboard'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.water),
                title: const Text('Tanks'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const TanksPage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.device_hub),
                title: const Text('Valves'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ValvesPage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.router),
                title: const Text('Devices'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const DevicesPage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.list_alt),
                title: const Text('Logs'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const LogsPage()));
                },
              ),
              const Spacer(),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, SettingsView.routeName);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  // For now, just pop to simulate logout; integrate real logout when auth added
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Connection Status Card
            if (_dashboardController.errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  color: Colors.red.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _dashboardController.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // System Overview
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'System Overview',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _OverviewMetric(
                            label: 'Total Valves',
                            value:
                                _dashboardController.valves.length.toString(),
                            icon: Icons.water_drop,
                          ),
                          _OverviewMetric(
                            label: 'Connected',
                            value: _dashboardController.valves.values
                                .where((v) => v.isConnected)
                                .length
                                .toString(),
                            icon: Icons.cloud_done,
                          ),
                          _OverviewMetric(
                            label: 'Open',
                            value: _dashboardController.valves.values
                                .where((v) => v.isOpen)
                                .length
                                .toString(),
                            icon: Icons.check_circle,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Flow Controller Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Flow Controller',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      LayoutBuilder(builder: (ctx, constraints) {
                        return Row(
                          children: [
                            // Semicircle Gauge
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  _MeterGauge(value: _computeSelectedAverage()),
                                  const SizedBox(height: 8),
                                  Text('Selected: ${_selectedValveIds.length}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Group controls
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Group Flow',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  Slider(
                                    value: _groupFlowValue,
                                    min: 0,
                                    max: 100,
                                    divisions: 100,
                                    label:
                                        '${_groupFlowValue.toStringAsFixed(0)}%',
                                    onChanged: (v) =>
                                        setState(() => _groupFlowValue = v),
                                  ),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: _selectedValveIds.isEmpty
                                            ? null
                                            : () => _applyFlowToSelected(
                                                _groupFlowValue),
                                        icon: const Icon(Icons.play_arrow),
                                        label: const Text('Apply to Selected'),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: _dbValves.isEmpty
                                            ? null
                                            : () => _applyFlowToAllValves(
                                                _groupFlowValue),
                                        icon: const Icon(Icons.water_drop),
                                        label: const Text('Apply to All'),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),

            // Tanks & Valves Card (tabular)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tanks & Valves',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: _dbValves.isEmpty
                            ? SizedBox(
                                width: MediaQuery.of(context).size.width - 64,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('No valves available',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium),
                                ),
                              )
                            : DataTable(
                                columns: const [
                                  DataColumn(label: Text('Select')),
                                  DataColumn(label: Text('Valve ID')),
                                  DataColumn(label: Text('Name')),
                                  DataColumn(label: Text('Tank')),
                                  DataColumn(label: Text('Node ID')),
                                  DataColumn(label: Text('Flow')),
                                  DataColumn(label: Text('Synced')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: _dbValves.map((v) {
                                  final tankName = _tanks
                                          .firstWhere((t) => t.id == v.tankId,
                                              orElse: () => Tank(tankId: '—'))
                                          .name ??
                                      '—';
                                  return DataRow(cells: [
                                    DataCell(Checkbox(
                                      value: _selectedValveIds.contains(v.id),
                                      onChanged: (val) {
                                        setState(() {
                                          if (val == true) {
                                            _selectedValveIds.add(v.id!);
                                          } else {
                                            _selectedValveIds.remove(v.id);
                                          }
                                        });
                                      },
                                    )),
                                    DataCell(Text(v.valveId ?? '—')),
                                    DataCell(Text(v.name ?? '—')),
                                    DataCell(Text(tankName)),
                                    DataCell(Text(v.nodeId?.toString() ?? '—')),
                                    DataCell(FutureBuilder<ValveState?>(
                                      future: v.id != null
                                          ? _valveStateService
                                              .getLatestStateForValve(v.id!)
                                          : Future.value(null),
                                      builder: (ctx, snap) {
                                        final latest = snap.data;
                                        final flow = latest?.flowRate
                                                ?.toStringAsFixed(0) ??
                                            '—';
                                        return Text('$flow%');
                                      },
                                    )),
                                    DataCell(Text(
                                        (v.synced ?? 0) == 1 ? 'Yes' : 'No')),
                                    DataCell(Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.settings),
                                          onPressed: () async {
                                            double temp = _groupFlowValue;
                                            final result =
                                                await showDialog<double>(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: Text(
                                                    'Set flow for ${v.name ?? v.valveId}'),
                                                content: StatefulBuilder(
                                                  builder: (c, setS) => Slider(
                                                    value: temp,
                                                    min: 0,
                                                    max: 100,
                                                    divisions: 100,
                                                    label:
                                                        '${temp.toStringAsFixed(0)}%',
                                                    onChanged: (vv) =>
                                                        setS(() => temp = vv),
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(ctx),
                                                      child:
                                                          const Text('Cancel')),
                                                  ElevatedButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              ctx, temp),
                                                      child:
                                                          const Text('Apply')),
                                                ],
                                              ),
                                            );
                                            if (result != null) {
                                              await _applyFlowToValve(
                                                  v, result);
                                              if (mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                        content: Text(
                                                            'Applied ${result.toStringAsFixed(0)}% to ${v.name ?? v.valveId}')));
                                              }
                                              _loadTanksAndValves();
                                            }
                                          },
                                        ),
                                      ],
                                    )),
                                  ]);
                                }).toList(),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_dashboardController.valves.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.water_drop,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No valves connected',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Waiting for data from MQTT broker...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Valve Stations',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                  ),
                  ..._dashboardController.valves.values.map((valve) {
                    return ValveCard(
                      valve: valve,
                      onOpen: () => _dashboardController.openValve(valve.id),
                      onClose: () => _dashboardController.closeValve(valve.id),
                      onFlowChange: (value) =>
                          _dashboardController.setFlowRate(valve.id, value),
                    );
                  }),
                ],
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Refresh',
        onPressed: _connectToBroker,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _OverviewMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _MeterGauge extends StatelessWidget {
  final double value; // 0..100

  const _MeterGauge({required this.value});

  @override
  Widget build(BuildContext context) {
    // Semicircular gauge: wider than tall
    return SizedBox(
      width: 220,
      height: 120,
      child: CustomPaint(
        painter: _SemiMeterPainter(value.clamp(0, 100)),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text('${value.toStringAsFixed(0)}%',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}

class _SemiMeterPainter extends CustomPainter {
  final double value; // 0..100

  _SemiMeterPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = min(size.width / 2, size.height) - 8;

    final basePaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..shader = const SweepGradient(
        startAngle: pi,
        endAngle: pi * 2,
        colors: [Colors.green, Colors.orange, Colors.red],
        stops: [0.0, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    // Full semicircle background
    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = pi; // left
    const fullSweep = pi; // 180 degrees
    canvas.drawArc(rect, startAngle, fullSweep, false, basePaint);

    // Progress arc
    final sweep = (value / 100) * fullSweep;
    canvas.drawArc(rect, startAngle, sweep, false, progressPaint);

    // Draw tick marks (major ticks)
    final tickPaint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 2;
    for (int i = 0; i <= 10; i++) {
      final t = i / 10;
      final angle = startAngle + fullSweep * t;
      final inner = Offset(center.dx + (radius - 12) * cos(angle),
          center.dy + (radius - 12) * sin(angle));
      final outer = Offset(center.dx + (radius + 2) * cos(angle),
          center.dy + (radius + 2) * sin(angle));
      canvas.drawLine(inner, outer, tickPaint);
    }

    // Pointer
    final pointerAngle = startAngle + sweep;
    final pointerLength = radius - 18;
    final px = center.dx + pointerLength * cos(pointerAngle);
    final py = center.dy + pointerLength * sin(pointerAngle);
    final pointerPaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(px, py), 6, pointerPaint);
  }

  @override
  bool shouldRepaint(covariant _SemiMeterPainter oldDelegate) =>
      oldDelegate.value != value;
}
