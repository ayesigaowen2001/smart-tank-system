class DeviceNode {
  final int? id;
  final String nodeId;
  final int? batteryLevel;
  final DateTime? lastSeen;
  final String? location;
  final DateTime? createdAt;
  final bool synced;

  DeviceNode({
    this.id,
    required this.nodeId,
    this.batteryLevel,
    this.lastSeen,
    this.location,
    this.createdAt,
    this.synced = false,
  });

  bool get isLowBattery => batteryLevel != null && batteryLevel! < 20;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'node_id': nodeId,
      'battery_level': batteryLevel,
      'last_seen': lastSeen?.toIso8601String(),
      'location': location,
      'created_at': createdAt?.toIso8601String(),
      'synced': synced ? 1 : 0,
    };
  }

  factory DeviceNode.fromMap(Map<String, dynamic> map) {
    return DeviceNode(
      id: map['id'],
      nodeId: map['node_id'],
      batteryLevel: map['battery_level'],
      lastSeen:
          map['last_seen'] != null ? DateTime.parse(map['last_seen']) : null,
      location: map['location'],
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      synced: map['synced'] == 1,
    );
  }

  DeviceNode copyWith({
    int? id,
    String? nodeId,
    int? batteryLevel,
    DateTime? lastSeen,
    String? location,
    DateTime? createdAt,
    bool? synced,
  }) {
    return DeviceNode(
      id: id ?? this.id,
      nodeId: nodeId ?? this.nodeId,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      lastSeen: lastSeen ?? this.lastSeen,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
    );
  }

  @override
  String toString() =>
      'DeviceNode(id: $id, nodeId: $nodeId, battery: $batteryLevel%)';
}
