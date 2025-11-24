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
}
