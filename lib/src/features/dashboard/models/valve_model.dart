class Valve {
  final int id;
  String status; // OPEN, CLOSED, OPENING, CLOSING
  double humidity;
  double batteryLevel;
  double flowRate; // 0-100%
  DateTime lastUpdate;
  bool isConnected;

  Valve({
    required this.id,
    this.status = 'UNKNOWN',
    this.humidity = 0.0,
    this.batteryLevel = 0.0,
    this.flowRate = 0.0,
    DateTime? lastUpdate,
    this.isConnected = false,
  }) : lastUpdate = lastUpdate ?? DateTime.now();

  // Factory constructor to create from MQTT message
  factory Valve.fromJson(Map<String, dynamic> json) {
    return Valve(
      id: json['id'] as int,
      status: json['status'] as String? ?? 'UNKNOWN',
      humidity: (json['humidity'] as num?)?.toDouble() ?? 0.0,
      batteryLevel: (json['battery'] as num?)?.toDouble() ?? 0.0,
      flowRate: (json['flow'] as num?)?.toDouble() ?? 0.0,
      lastUpdate: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      isConnected: json['isConnected'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'humidity': humidity,
      'battery': batteryLevel,
      'flow': flowRate,
      'timestamp': lastUpdate.toIso8601String(),
      'isConnected': isConnected,
    };
  }

  bool get isLowBattery => batteryLevel < 3.5;
  bool get isHighHumidity => humidity > 80;
  bool get isOpen => status == 'OPEN';
}
