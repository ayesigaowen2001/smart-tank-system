import 'package:flutter/material.dart';
import '../models/tank.dart';
import '../services/tank_service.dart';

class TanksPage extends StatefulWidget {
  const TanksPage({super.key});

  @override
  State<TanksPage> createState() => _TanksPageState();
}

class _TanksPageState extends State<TanksPage> {
  late TankService _tankService;
  late Future<List<Tank>> _tanksFuture;

  @override
  void initState() {
    super.initState();
    _tankService = TankService();
    _tanksFuture = _tankService.getAllTanks();
  }

  void _refreshData() {
    setState(() {
      _tanksFuture = _tankService.getAllTanks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tanks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<List<Tank>>(
        future: _tanksFuture,
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

          final tanks = snapshot.data ?? [];

          if (tanks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.water, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No tanks found',
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
                  DataColumn(label: Text('Tank ID')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Location')),
                  DataColumn(label: Text('Capacity (L)')),
                  DataColumn(label: Text('Current Level (L)')),
                  DataColumn(label: Text('Fill %')),
                  DataColumn(label: Text('Last Updated')),
                  DataColumn(label: Text('Synced')),
                ],
                rows: tanks
                    .map(
                      (tank) => DataRow(
                        cells: [
                          DataCell(Text(tank.id?.toString() ?? 'N/A')),
                          DataCell(Text(tank.tankId)),
                          DataCell(Text(tank.name ?? 'N/A')),
                          DataCell(Text(tank.location ?? 'N/A')),
                          DataCell(Text(
                              tank.capacityLiters?.toStringAsFixed(2) ??
                                  'N/A')),
                          DataCell(Text(
                              tank.currentLevel?.toStringAsFixed(2) ?? 'N/A')),
                          DataCell(
                            Text(
                              tank.fillPercentage != null
                                  ? '${tank.fillPercentage!.toStringAsFixed(1)}%'
                                  : 'N/A',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: tank.fillPercentage != null
                                    ? (tank.fillPercentage! > 80
                                        ? Colors.green
                                        : tank.fillPercentage! > 50
                                            ? Colors.orange
                                            : Colors.red)
                                    : Colors.grey,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              tank.lastUpdated?.toString().split('.')[0] ??
                                  'N/A',
                            ),
                          ),
                          DataCell(
                            Chip(
                              label: Text(tank.synced ? 'Yes' : 'No'),
                              backgroundColor:
                                  tank.synced ? Colors.green : Colors.orange,
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
