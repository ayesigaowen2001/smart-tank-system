class Valve {
  final int? id;
  final String valveId;
  final int? nodeId;
  final int? tankId;
  final String? name;
  final String? description;
  final DateTime? createdAt;
  final bool synced;

  Valve({
    this.id,
    required this.valveId,
    this.nodeId,
    this.tankId,
    this.name,
    this.description,
    this.createdAt,
    this.synced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'valve_id': valveId,
      'node_id': nodeId,
      'tank_id': tankId,
      'name': name,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
      'synced': synced ? 1 : 0,
    };
  }

  factory Valve.fromMap(Map<String, dynamic> map) {
    return Valve(
      id: map['id'],
      valveId: map['valve_id'],
      nodeId: map['node_id'],
      tankId: map['tank_id'],
      name: map['name'],
      description: map['description'],
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      synced: map['synced'] == 1,
    );
  }

  Valve copyWith({
    int? id,
    String? valveId,
    int? nodeId,
    int? tankId,
    String? name,
    String? description,
    DateTime? createdAt,
    bool? synced,
  }) {
    return Valve(
      id: id ?? this.id,
      valveId: valveId ?? this.valveId,
      nodeId: nodeId ?? this.nodeId,
      tankId: tankId ?? this.tankId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
    );
  }

  @override
  String toString() => 'Valve(id: $id, valveId: $valveId, nodeId: $nodeId)';
}
