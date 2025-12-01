import 'package:flutter/material.dart';
import '../models/valve_model.dart';

class ValveCard extends StatelessWidget {
  final Valve valve;
  final VoidCallback onOpen;
  final VoidCallback onClose;
  final Function(double) onFlowChange;

  const ValveCard({
    super.key,
    required this.valve,
    required this.onOpen,
    required this.onClose,
    required this.onFlowChange,
  });

  Color _getStatusColor() {
    if (!valve.isConnected) return Colors.grey;
    switch (valve.status) {
      case 'OPEN':
        return Colors.green;
      case 'CLOSED':
        return Colors.red;
      case 'OPENING':
      case 'CLOSING':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Icon _getStatusIcon() {
    switch (valve.status) {
      case 'OPEN':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'CLOSED':
        return const Icon(Icons.cancel, color: Colors.red);
      case 'OPENING':
      case 'CLOSING':
        return const Icon(Icons.autorenew, color: Colors.orange);
      default:
        return const Icon(Icons.help, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with valve ID and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Valve ${valve.id}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _getStatusIcon(),
                        const SizedBox(width: 8),
                        Text(
                          valve.status,
                          style: TextStyle(
                            color: _getStatusColor(),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!valve.isConnected)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Text('(Disconnected)',
                                style: TextStyle(color: Colors.grey)),
                          ),
                      ],
                    ),
                  ],
                ),
                Text(
                  'Last: ${valve.lastUpdate.hour}:${valve.lastUpdate.minute.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sensor readings
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SensorReadingWidget(
                  icon: Icons.opacity,
                  label: 'Humidity',
                  value: '${valve.humidity.toStringAsFixed(1)}%',
                  color: valve.isHighHumidity ? Colors.orange : Colors.blue,
                ),
                _SensorReadingWidget(
                  icon: Icons.battery_full,
                  label: 'Battery',
                  value: '${valve.batteryLevel.toStringAsFixed(2)}V',
                  color: valve.isLowBattery ? Colors.red : Colors.green,
                ),
                _SensorReadingWidget(
                  icon: Icons.water_drop,
                  label: 'Flow',
                  value: '${valve.flowRate.toStringAsFixed(0)}%',
                  color: Colors.cyan,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Flow rate slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Flow Rate Control',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Slider(
                  value: valve.flowRate,
                  min: 0,
                  max: 100,
                  divisions: 10,
                  label: '${valve.flowRate.toStringAsFixed(0)}%',
                  onChanged: onFlowChange,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: valve.isConnected ? onOpen : null,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Open'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: valve.isConnected ? onClose : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Close'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SensorReadingWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SensorReadingWidget({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
      ],
    );
  }
}
