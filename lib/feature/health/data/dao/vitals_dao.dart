import 'package:drift/drift.dart';
import 'package:hubo/core/db/app_database.dart';
import 'package:hubo/feature/health/data/model/vital_model.dart';

part 'vitals_dao.g.dart';

@DriftAccessor(tables: [Vitals])
class VitalsDao extends DatabaseAccessor<AppDb> with _$VitalsDaoMixin {
  final AppDb db;

  VitalsDao(this.db) : super(db);

  Future<int> insertVital(VitalsCompanion companion) =>
      into(db.vitals).insert(companion);

  Future<List<Vital>> getUnsyncedVitals() {
    return (select(db.vitals)..where((t) => t.syncStatus.equals(0))).get();
  }

  Future<void> markAsSynced(int id) async {
    await (update(db.vitals)..where((t) => t.id.equals(id))).write(
      VitalsCompanion(syncStatus: const Value(1)),
    );
  }

  Future<List<Vital>> fetchRecent({int limit = 7}) {
    return (select(db.vitals)
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ])
          ..limit(limit))
        .get();
  }

  Future<void> insertMockVitals() async {
    final now = DateTime.now();

    final mockEntries = List.generate(7, (index) {
      final date = now.subtract(Duration(days: index));

      final hr = 65 + (index * 2); // heart rate
      final stepsVal = 3000 + (index * 600);
      final sleep = 6 + (index % 3);

      return VitalsCompanion.insert(
        heartRate: hr,
        steps: stepsVal,
        sleepHours: sleep.toDouble(),
        createdAt: date,
        // syncStatus defaults to 0
      );
    });

    await db.batch((batch) {
      batch.insertAll(db.vitals, mockEntries);
    });
  }

  Future<bool> hasVitals() async {
    final list = await db.select(db.vitals).get();
    return list.isNotEmpty;
  }

  Future<void> ensureMockVitalsIfEmpty() async {
    final hasAny = await hasVitals();
    if (!hasAny) {
      await insertMockVitals();
    }
  }

  Future<void> clearVitals() async {
    await delete(db.vitals).go();
  }
}
