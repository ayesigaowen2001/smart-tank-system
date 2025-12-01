import 'package:flutter/material.dart';
import '../models/valve.dart';
import '../services/valve_service.dart';

class ValvesPage extends StatefulWidget {
  const ValvesPage({super.key});

  @override
  State<ValvesPage> createState() => _ValvesPageState();
}

class _ValvesPageState extends State<ValvesPage> {
  late ValveService _valveService;
  late Future<List<Valve>> _valvesFuture;

  @override
  void initState() {
    super.initState();
    _valveService = ValveService();
    _valvesFuture = _valveService.getAllValves();
  }

  void _refreshData() {
    setState(() {
      _valvesFuture = _valveService.getAllValves();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Valves'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<List<Valve>>(
        future: _valvesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final valves = snapshot.data ?? [];

          if (valves.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.device_hub, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No valves found',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Valve ID')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Description')),
                  DataColumn(label: Text('Node ID')),
                  DataColumn(label: Text('Created')),
                  DataColumn(label: Text('Synced')),
                ],
                rows: valves
                    .map(
                      (valve) => DataRow(
                        cells: [
                          DataCell(Text(valve.id?.toString() ?? 'N/A')),
                          DataCell(Text(valve.valveId)),
                          DataCell(Text(valve.name ?? 'N/A')),
                          DataCell(
                            SizedBox(
                              width: 200,
                              child: Text(
                                valve.description ?? 'N/A',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(Text(valve.nodeId?.toString() ?? 'N/A')),
                          DataCell(
                            Text(
                              valve.createdAt?.toString().split('.')[0] ??
                                  'N/A',
                            ),
                          ),
                          DataCell(
                            Chip(
                              label: Text(valve.synced ? 'Yes' : 'No'),
                              backgroundColor:
                                  valve.synced ? Colors.green : Colors.orange,
                              labelStyle: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshData,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
