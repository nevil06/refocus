enum SessionStatus {
  active,
  completed,
  cancelled,
  interrupted;

  static SessionStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'completed':
        return SessionStatus.completed;
      case 'cancelled':
        return SessionStatus.cancelled;
      case 'interrupted':
        return SessionStatus.interrupted;
      case 'active':
      default:
        return SessionStatus.active;
    }
  }
}

class FocusSessionModel {
  final String id;
  final DateTime startTime;
  final DateTime plannedEndTime;
  final int durationSeconds;
  final SessionStatus status;
  final bool isStrictMode;
  final DateTime createdAt;
  final DateTime? completedAt;
  final List<String> blockedApps;
  final String? label;

  FocusSessionModel({
    required this.id,
    required this.startTime,
    required this.plannedEndTime,
    required this.durationSeconds,
    required this.status,
    required this.isStrictMode,
    required this.createdAt,
    this.completedAt,
    required this.blockedApps,
    this.label,
  });

  int get remainingSeconds {
    final now = DateTime.now();
    final diff = plannedEndTime.difference(now).inSeconds;
    return diff > 0 ? diff : 0;
  }

  int get elapsedSeconds {
    final now = DateTime.now();
    final elapsed = now.difference(startTime).inSeconds;
    if (elapsed < 0) return 0;
    if (elapsed > durationSeconds) return durationSeconds;
    return elapsed;
  }

  double get progressFraction {
    if (durationSeconds <= 0) return 0.0;
    final progress = elapsedSeconds / durationSeconds;
    return progress.clamp(0.0, 1.0);
  }

  bool get isExpired => DateTime.now().isAfter(plannedEndTime);

  FocusSessionModel copyWith({
    String? id,
    DateTime? startTime,
    DateTime? plannedEndTime,
    int? durationSeconds,
    SessionStatus? status,
    bool? isStrictMode,
    DateTime? createdAt,
    DateTime? completedAt,
    List<String>? blockedApps,
    String? label,
  }) {
    return FocusSessionModel(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      plannedEndTime: plannedEndTime ?? this.plannedEndTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      status: status ?? this.status,
      isStrictMode: isStrictMode ?? this.isStrictMode,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      blockedApps: blockedApps ?? this.blockedApps,
      label: label ?? this.label,
    );
  }
}
