import 'package:flutter/material.dart';
import '../models/device_node.dart';
import '../services/device_service.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  late DeviceService _deviceService;
  late Future<List<DeviceNode>> _devicesFuture;

  @override
  void initState() {
    super.initState();
    _deviceService = DeviceService();
    _devicesFuture = _deviceService.getAllDevices();
  }

  void _refreshData() {
    setState(() {
      _devicesFuture = _deviceService.getAllDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices (Nodes)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<List<DeviceNode>>(
        future: _devicesFuture,
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

          final devices = snapshot.data ?? [];

          if (devices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.router, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No devices found',
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
                  DataColumn(label: Text('Node ID')),
                  DataColumn(label: Text('Battery %')),
                  DataColumn(label: Text('Battery Status')),
                  DataColumn(label: Text('Location')),
                  DataColumn(label: Text('Last Seen')),
                  DataColumn(label: Text('Created')),
                  DataColumn(label: Text('Synced')),
                ],
                rows: devices
                    .map(
                      (device) => DataRow(
                        cells: [
                          DataCell(Text(device.id?.toString() ?? 'N/A')),
                          DataCell(Text(device.nodeId)),
                          DataCell(
                              Text(device.batteryLevel?.toString() ?? 'N/A')),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: device.isLowBattery
                                    ? Colors.red
                                    : Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                device.isLowBattery ? 'Low' : 'Good',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text(device.location ?? 'N/A')),
                          DataCell(
                            Text(
                              device.lastSeen?.toString().split('.')[0] ??
                                  'N/A',
                            ),
                          ),
                          DataCell(
                            Text(
                              device.createdAt?.toString().split('.')[0] ??
                                  'N/A',
                            ),
                          ),
                          DataCell(
                            Chip(
                              label: Text(device.synced ? 'Yes' : 'No'),
                              backgroundColor:
                                  device.synced ? Colors.green : Colors.orange,
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
