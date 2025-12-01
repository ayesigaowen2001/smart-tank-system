class ValveState {
  final int? id;
  final int valveId;
  final String state; // 'open' or 'closed'
  final double? flowRate;
  final DateTime timestamp;
  final bool synced;

  ValveState({
    this.id,
    required this.valveId,
    required this.state,
    this.flowRate,
    DateTime? timestamp,
    this.synced = false,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isOpen => state.toLowerCase() == 'open';
  bool get isClosed => state.toLowerCase() == 'closed';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'valve_id': valveId,
      'state': state,
      'flow_rate': flowRate,
      'timestamp': timestamp.toIso8601String(),
      'synced': synced ? 1 : 0,
    };
  }

  factory ValveState.fromMap(Map<String, dynamic> map) {
    return ValveState(
      id: map['id'],
      valveId: map['valve_id'],
      state: map['state'],
      flowRate: map['flow_rate']?.toDouble(),
      timestamp: DateTime.parse(map['timestamp']),
      synced: map['synced'] == 1,
    );
  }

  ValveState copyWith({
    int? id,
    int? valveId,
    String? state,
    double? flowRate,
    DateTime? timestamp,
    bool? synced,
  }) {
    return ValveState(
      id: id ?? this.id,
      valveId: valveId ?? this.valveId,
      state: state ?? this.state,
      flowRate: flowRate ?? this.flowRate,
      timestamp: timestamp ?? this.timestamp,
      synced: synced ?? this.synced,
    );
  }

  @override
  String toString() =>
      'ValveState(id: $id, valveId: $valveId, state: $state, flowRate: $flowRate)';
}
