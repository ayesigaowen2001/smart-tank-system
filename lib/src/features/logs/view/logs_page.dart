import 'package:flutter/material.dart';
import '../models/log_entry.dart';
import '../services/log_service.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  late LogService _logService;
  late Future<List<LogEntry>> _logsFuture;
  String _selectedLevel = 'all';

  @override
  void initState() {
    super.initState();
    _logService = LogService();
    _logsFuture = _logService.getAllLogs();
  }

  void _refreshData() {
    setState(() {
      if (_selectedLevel == 'all') {
        _logsFuture = _logService.getAllLogs();
      } else {
        _logsFuture = _logService.getLogsByLevel(_selectedLevel);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Text('Filter by Level: '),
                  const SizedBox(width: 8),
                  ...[
                    ('all', 'All'),
                    ('info', 'Info'),
                    ('warning', 'Warning'),
                    ('error', 'Error'),
                  ].map((level) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: Text(level.$2),
                        selected: _selectedLevel == level.$1,
                        onSelected: (selected) {
                          setState(() {
                            _selectedLevel = level.$1;
                            _refreshData();
                          });
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<LogEntry>>(
              future: _logsFuture,
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

                final logs = snapshot.data ?? [];

                if (logs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.list_alt, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No logs found',
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
                        DataColumn(label: Text('Timestamp')),
                        DataColumn(label: Text('Level')),
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('Message')),
                        DataColumn(label: Text('Node ID')),
                        DataColumn(label: Text('Valve ID')),
                        DataColumn(label: Text('Synced')),
                      ],
                      rows: logs
                          .map(
                            (log) => DataRow(
                              cells: [
                                DataCell(Text(log.id?.toString() ?? 'N/A')),
                                DataCell(
                                  Text(log.timestamp.toString().split('.')[0]),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: log.level == 'error'
                                          ? Colors.red
                                          : log.level == 'warning'
                                              ? Colors.orange
                                              : Colors.blue,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      log.level.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(Text(log.logType)),
                                DataCell(
                                  SizedBox(
                                    width: 250,
                                    child: Text(
                                      log.message,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(Text(log.nodeId?.toString() ?? 'N/A')),
                                DataCell(
                                    Text(log.valveId?.toString() ?? 'N/A')),
                                DataCell(
                                  Chip(
                                    label: Text(log.synced ? 'Yes' : 'No'),
                                    backgroundColor: log.synced
                                        ? Colors.green
                                        : Colors.orange,
                                    labelStyle:
                                        const TextStyle(color: Colors.white),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshData,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
