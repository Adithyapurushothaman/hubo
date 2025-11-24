import 'package:hubo/feature/health/domain/entities/vital_entity.dart';

abstract class VitalsRepository {
  /// Adds a new vital reading to local storage and returns the local id.
  Future<int> addVital(VitalEntity vital);

  /// Returns unsynced vitals (syncStatus == 0).
  Future<List<VitalEntity>> getUnsyncedVitals();

  /// Marks a local vital row as synced.
  Future<void> markAsSynced(int id);

  /// Fetch most recent N vitals (default 7)
  Future<List<VitalEntity>> fetchRecent({int limit = 7});
}
