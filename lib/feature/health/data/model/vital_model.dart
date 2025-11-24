import 'package:drift/drift.dart';

class Vitals extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get heartRate => integer().named('heart_rate')();

  IntColumn get steps => integer()();

  RealColumn get sleepHours => real().named('sleep_hours')();

  DateTimeColumn get createdAt => dateTime().named('created_at')();

  /// 0 = pending/unsynced, 1 = synced
  IntColumn get syncStatus =>
      integer().named('sync_status').withDefault(const Constant(0))();
}
