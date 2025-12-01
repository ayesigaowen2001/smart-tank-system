class Telemetry {
  final int? id;
  final int nodeId;
  final double? humidity;
  final double? temperature;
  final int? battery;
  final int? rssi;
  final DateTime timestamp;
  final bool synced;

  Telemetry({
    this.id,
    required this.nodeId,
    this.humidity,
    this.temperature,
    this.battery,
    this.rssi,
    DateTime? timestamp,
    this.synced = false,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'node_id': nodeId,
      'humidity': humidity,
      'temperature': temperature,
      'battery': battery,
      'rssi': rssi,
      'timestamp': timestamp.toIso8601String(),
      'synced': synced ? 1 : 0,
    };
  }

  factory Telemetry.fromMap(Map<String, dynamic> map) {
    return Telemetry(
      id: map['id'],
      nodeId: map['node_id'],
      humidity: map['humidity']?.toDouble(),
      temperature: map['temperature']?.toDouble(),
      battery: map['battery'],
      rssi: map['rssi'],
      timestamp: DateTime.parse(map['timestamp']),
      synced: map['synced'] == 1,
    );
  }

  Telemetry copyWith({
    int? id,
    int? nodeId,
    double? humidity,
    double? temperature,
    int? battery,
    int? rssi,
    DateTime? timestamp,
    bool? synced,
  }) {
    return Telemetry(
      id: id ?? this.id,
      nodeId: nodeId ?? this.nodeId,
      humidity: humidity ?? this.humidity,
      temperature: temperature ?? this.temperature,
      battery: battery ?? this.battery,
      rssi: rssi ?? this.rssi,
      timestamp: timestamp ?? this.timestamp,
      synced: synced ?? this.synced,
    );
  }

  @override
  String toString() =>
      'Telemetry(id: $id, nodeId: $nodeId, humidity: $humidity, temp: $temperature)';
}
