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

enum StrictModeType {
  off,      // Normal Mode: "Give up and Stop" available immediately
  friction, // Existing Strict Mode: 5s countdown + type "STOP"
  locked;   // Locked Mode (NEW): No cancel UI anywhere, natural timer completion only

  static StrictModeType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'locked':
        return StrictModeType.locked;
      case 'friction':
      case 'strict':
      case 'true':
        return StrictModeType.friction;
      case 'off':
      case 'false':
      default:
        return StrictModeType.off;
    }
  }

  static StrictModeType fromInt(int? value) {
    switch (value) {
      case 2:
        return StrictModeType.locked;
      case 1:
        return StrictModeType.friction;
      case 0:
      default:
        return StrictModeType.off;
    }
  }

  int toInt() {
    switch (this) {
      case StrictModeType.locked:
        return 2;
      case StrictModeType.friction:
        return 1;
      case StrictModeType.off:
        return 0;
    }
  }

  String get displayName {
    switch (this) {
      case StrictModeType.locked:
        return 'Locked (No Exit)';
      case StrictModeType.friction:
        return 'Friction (5s + STOP)';
      case StrictModeType.off:
        return 'Off (Normal)';
    }
  }
}

class FocusSessionModel {
  final String id;
  final DateTime startTime;
  final DateTime plannedEndTime;
  final int durationSeconds;
  final SessionStatus status;
  final StrictModeType strictModeType;
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
    StrictModeType? strictModeType,
    bool? isStrictMode,
    required this.createdAt,
    this.completedAt,
    required this.blockedApps,
    this.label,
  }) : strictModeType = strictModeType ??
            (isStrictMode == true ? StrictModeType.friction : StrictModeType.off);

  bool get isStrictMode => strictModeType != StrictModeType.off;
  bool get isLockedMode => strictModeType == StrictModeType.locked;
  bool get isFrictionMode => strictModeType == StrictModeType.friction;

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
    StrictModeType? strictModeType,
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
      strictModeType: strictModeType ??
          (isStrictMode != null
              ? (isStrictMode ? StrictModeType.friction : StrictModeType.off)
              : this.strictModeType),
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      blockedApps: blockedApps ?? this.blockedApps,
      label: label ?? this.label,
    );
  }
}
