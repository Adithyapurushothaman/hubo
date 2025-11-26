import 'package:drift/drift.dart';
import 'package:hubo/core/db/app_database.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hubo/feature/health/data/dao/vitals_dao.dart';
import 'package:hubo/feature/health/domain/entities/vital_entity.dart';
import 'package:hubo/feature/health/domain/repositories/vitals_repository.dart';

/// Data-layer implementation of [VitalsRepository], talks to Drift DAOs.
class VitalsRepositoryImpl implements VitalsRepository {
  final AppDb db;
  final VitalsDao vitalsDao = VitalsDao(appDb);

  VitalsRepositoryImpl(this.db);

  @override
  Future<int> addVital(VitalEntity vital) async {
    // Decide sync status based on current connectivity.
    // As requested: when network is present -> syncStatus = 0,
    // when network is not present -> syncStatus = 1.
    int status = 0;
    try {
      final conn = await Connectivity().checkConnectivity();
      status = conn != ConnectivityResult.none ? 0 : 1;
    } catch (_) {
      // If connectivity check fails, conservatively assume offline.
      status = 1;
    }

    final companion = VitalsCompanion.insert(
      heartRate: vital.heartRate,
      steps: vital.steps,
      sleepHours: vital.sleepHours,
      createdAt: vital.createdAt,
      syncStatus: Value(status),
    );

    return await vitalsDao.insertVital(companion);

    // return await db.into(db.vitals).insert(companion);
  }

  @override
  Future<List<VitalEntity>> getUnsyncedVitals() async {
    // final rows = await (db.select(
    //   db.vitals,
    // )..where((t) => t.syncStatus.equals(0))).get();
    // return rows.map(_mapRowToEntity).toList();
    return (await vitalsDao.getUnsyncedVitals()).map(_mapRowToEntity).toList();
  }

  @override
  Future<void> markAsSynced(int id) async {
    // await (db.update(db.vitals)..where((t) => t.id.equals(id))).write(
    //   VitalsCompanion(syncStatus: const Value(1)),
    // );
    await vitalsDao.markAsSynced(id);
  }

  @override
  Future<List<VitalEntity>> fetchRecent({int limit = 7}) async {
    return (await vitalsDao.fetchRecent(
      limit: limit,
    )).map(_mapRowToEntity).toList();
  }

  VitalEntity _mapRowToEntity(Vital row) => VitalEntity(
    id: row.id,
    heartRate: row.heartRate,
    steps: row.steps,
    sleepHours: row.sleepHours,
    createdAt: row.createdAt,
    syncStatus: row.syncStatus,
  );

  @override
  Future<bool> hasVitals() {
    return vitalsDao.hasVitals();
  }

  @override
  Future<void> insertMockVitals() {
    return vitalsDao.insertMockVitals();
  }

  @override
  Future<void> ensureMockVitalsIfEmpty() {
    return vitalsDao.ensureMockVitalsIfEmpty();
  }

  @override
  Future<void> clearAllVitals() {
    return vitalsDao.clearVitals();
  }
}
