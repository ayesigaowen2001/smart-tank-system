class LogEntry {
  final int? id;
  final String logType;
  final String message;
  final int? nodeId;
  final int? valveId;
  final String level; // 'info', 'warning', 'error'
  final DateTime timestamp;
  final bool synced;

  LogEntry({
    this.id,
    required this.logType,
    required this.message,
    this.nodeId,
    this.valveId,
    this.level = 'info',
    DateTime? timestamp,
    this.synced = false,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'log_type': logType,
      'message': message,
      'node_id': nodeId,
      'valve_id': valveId,
      'level': level,
      'timestamp': timestamp.toIso8601String(),
      'synced': synced ? 1 : 0,
    };
  }

  factory LogEntry.fromMap(Map<String, dynamic> map) {
    return LogEntry(
      id: map['id'],
      logType: map['log_type'],
      message: map['message'],
      nodeId: map['node_id'],
      valveId: map['valve_id'],
      level: map['level'] ?? 'info',
      timestamp: DateTime.parse(map['timestamp']),
      synced: map['synced'] == 1,
    );
  }

  LogEntry copyWith({
    int? id,
    String? logType,
    String? message,
    int? nodeId,
    int? valveId,
    String? level,
    DateTime? timestamp,
    bool? synced,
  }) {
    return LogEntry(
      id: id ?? this.id,
      logType: logType ?? this.logType,
      message: message ?? this.message,
      nodeId: nodeId ?? this.nodeId,
      valveId: valveId ?? this.valveId,
      level: level ?? this.level,
      timestamp: timestamp ?? this.timestamp,
      synced: synced ?? this.synced,
    );
  }

  @override
  String toString() =>
      'LogEntry(id: $id, type: $logType, level: $level, message: $message)';
}
