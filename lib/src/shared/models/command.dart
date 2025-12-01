class Command {
  final int? id;
  final int? valveId;
  final int? userId;
  final String commandType; // 'open', 'close', 'set_flow'
  final String? payload; // JSON string
  final String status; // 'sent', 'delivered', 'failed'
  final DateTime timestamp;
  final bool synced;

  Command({
    this.id,
    this.valveId,
    this.userId,
    required this.commandType,
    this.payload,
    this.status = 'sent',
    DateTime? timestamp,
    this.synced = false,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'valve_id': valveId,
      'user_id': userId,
      'command_type': commandType,
      'payload': payload,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'synced': synced ? 1 : 0,
    };
  }

  factory Command.fromMap(Map<String, dynamic> map) {
    return Command(
      id: map['id'],
      valveId: map['valve_id'],
      userId: map['user_id'],
      commandType: map['command_type'],
      payload: map['payload'],
      status: map['status'],
      timestamp: DateTime.parse(map['timestamp']),
      synced: map['synced'] == 1,
    );
  }

  Command copyWith({
    int? id,
    int? valveId,
    int? userId,
    String? commandType,
    String? payload,
    String? status,
    DateTime? timestamp,
    bool? synced,
  }) {
    return Command(
      id: id ?? this.id,
      valveId: valveId ?? this.valveId,
      userId: userId ?? this.userId,
      commandType: commandType ?? this.commandType,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      synced: synced ?? this.synced,
    );
  }

  @override
  String toString() =>
      'Command(id: $id, valveId: $valveId, type: $commandType, status: $status)';
}
