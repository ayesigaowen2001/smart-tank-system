import 'package:flutter/material.dart';
import '../utils/sample_data_generator.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  bool _isGenerating = false;
  String _statusMessage = '';
  int _recordCount = 0;

  Future<void> _generateSampleData() async {
    setState(() {
      _isGenerating = true;
      _statusMessage = 'Generating sample data...';
      _recordCount = 0;
    });

    try {
      await SampleDataGenerator.generateAllSampleData();
      setState(() {
        _statusMessage = '✅ Sample data generated successfully!';
        _recordCount = 250; // Approximately
        _isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                '✅ Sample data generated! Navigate to Tanks/Valves/Devices/Logs to view.'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error: $e';
        _isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearAllData() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
            'This will delete all sample data from the database. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await SampleDataGenerator.clearAllData();
                setState(() {
                  _statusMessage = '✅ All data cleared!';
                  _recordCount = 0;
                });

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ All data cleared!'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              } catch (e) {
                setState(() {
                  _statusMessage = '❌ Error clearing data: $e';
                });
              }
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug & Testing'),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status Card
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _statusMessage.isEmpty
                            ? 'Ready to generate sample data'
                            : _statusMessage,
                        style: TextStyle(
                          fontSize: 16,
                          color: _statusMessage.contains('✅')
                              ? Colors.green
                              : _statusMessage.contains('❌')
                                  ? Colors.red
                                  : Colors.blue,
                        ),
                      ),
                      if (_recordCount > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Generated ~$_recordCount records',
                            style: const TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Generate Data Button
              ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateSampleData,
                icon: _isGenerating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: Text(
                  _isGenerating ? 'Generating...' : 'Generate Sample Data',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 12),

              // Clear Data Button
              ElevatedButton.icon(
                onPressed: _isGenerating ? null : _clearAllData,
                icon: const Icon(Icons.delete),
                label: const Text('Clear All Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 32),

              // Info Card
              Card(
                color: Colors.amber.shade50,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What Gets Generated',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      _InfoItem(label: 'Devices (Nodes)', value: '3'),
                      _InfoItem(label: 'Valves', value: '5'),
                      _InfoItem(label: 'Valve State Changes', value: '50'),
                      _InfoItem(label: 'Tanks', value: '2'),
                      _InfoItem(label: 'Telemetry Readings', value: '60'),
                      _InfoItem(label: 'Log Entries', value: '50'),
                      _InfoItem(label: 'Commands', value: '20'),
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Total: ~250 records',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Next Steps Card
              Card(
                color: Colors.purple.shade50,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Steps',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      _StepItem(
                        number: '1',
                        title: 'Generate Data',
                        description:
                            'Click "Generate Sample Data" button above',
                      ),
                      _StepItem(
                        number: '2',
                        title: 'Open Navigation Drawer',
                        description: 'Close this screen and tap the menu icon',
                      ),
                      _StepItem(
                        number: '3',
                        title: 'Browse Data Pages',
                        description: 'Click on Tanks, Valves, Devices, or Logs',
                      ),
                      _StepItem(
                        number: '4',
                        title: 'Test Functionality',
                        description:
                            'Tap refresh buttons and test filters (on Logs)',
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          '✨ You should see populated tables with real data!',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Testing Checklist
              Card(
                color: Colors.cyan.shade50,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Testing Checklist',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      _ChecklistItem(
                        icon: Icons.water,
                        text:
                            '📊 Tanks page shows table with fill % indicators',
                      ),
                      _ChecklistItem(
                        icon: Icons.device_hub,
                        text: '🚰 Valves page shows valve list',
                      ),
                      _ChecklistItem(
                        icon: Icons.router,
                        text: '📱 Devices page shows nodes with battery status',
                      ),
                      _ChecklistItem(
                        icon: Icons.list_alt,
                        text: '📝 Logs page shows logs with filter chips',
                      ),
                      _ChecklistItem(
                        icon: Icons.refresh,
                        text: '🔄 Refresh buttons work on all pages',
                      ),
                      _ChecklistItem(
                        icon: Icons.filter_alt,
                        text: '🎯 Logs filter works (Info/Warning/Error)',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const _StepItem({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.purple,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ChecklistItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.cyan, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
