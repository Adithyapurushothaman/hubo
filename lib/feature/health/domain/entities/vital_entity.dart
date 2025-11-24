class VitalEntity {
  VitalEntity({
    required this.id,
    required this.heartRate,
    required this.steps,
    required this.sleepHours,
    required this.createdAt,
    required this.syncStatus,
  });

  final int? id;
  final int heartRate;
  final int steps;
  final double sleepHours;
  final DateTime createdAt;

  /// 0 = pending, 1 = synced
  final int syncStatus;
}
