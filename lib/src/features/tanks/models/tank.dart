class Tank {
  final int? id;
  final String tankId;
  final String? name;
  final String? location;
  final double? capacityLiters;
  final double? currentLevel;
  final DateTime? lastUpdated;
  final DateTime? createdAt;
  final bool synced;

  Tank({
    this.id,
    required this.tankId,
    this.name,
    this.location,
    this.capacityLiters,
    this.currentLevel,
    this.lastUpdated,
    this.createdAt,
    this.synced = false,
  });

  double? get fillPercentage {
    if (capacityLiters == null || capacityLiters == 0 || currentLevel == null) {
      return null;
    }
    return (currentLevel! / capacityLiters!) * 100;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tank_id': tankId,
      'name': name,
      'location': location,
      'capacity_liters': capacityLiters,
      'current_level': currentLevel,
      'last_updated': lastUpdated?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'synced': synced ? 1 : 0,
    };
  }

  factory Tank.fromMap(Map<String, dynamic> map) {
    return Tank(
      id: map['id'],
      tankId: map['tank_id'],
      name: map['name'],
      location: map['location'],
      capacityLiters: map['capacity_liters']?.toDouble(),
      currentLevel: map['current_level']?.toDouble(),
      lastUpdated: map['last_updated'] != null
          ? DateTime.parse(map['last_updated'])
          : null,
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      synced: map['synced'] == 1,
    );
  }

  Tank copyWith({
    int? id,
    String? tankId,
    String? name,
    String? location,
    double? capacityLiters,
    double? currentLevel,
    DateTime? lastUpdated,
    DateTime? createdAt,
    bool? synced,
  }) {
    return Tank(
      id: id ?? this.id,
      tankId: tankId ?? this.tankId,
      name: name ?? this.name,
      location: location ?? this.location,
      capacityLiters: capacityLiters ?? this.capacityLiters,
      currentLevel: currentLevel ?? this.currentLevel,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
    );
  }

  @override
  String toString() => 'Tank(id: $id, tankId: $tankId, name: $name)';
}
