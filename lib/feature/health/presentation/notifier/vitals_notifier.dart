import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hubo/feature/health/domain/entities/vital_entity.dart';
import 'package:hubo/feature/health/data/providers.dart';

part 'vitals_notifier.g.dart';

class VitalsState {
  const VitalsState({
    required this.recent,
    required this.unsyncedCount,
    required this.isLoading,
  });

  final List<VitalEntity> recent;
  final int unsyncedCount;
  final bool isLoading;

  factory VitalsState.initial() =>
      const VitalsState(recent: [], unsyncedCount: 0, isLoading: false);

  VitalsState copyWith({
    List<VitalEntity>? recent,
    int? unsyncedCount,
    bool? isLoading,
  }) {
    return VitalsState(
      recent: recent ?? this.recent,
      unsyncedCount: unsyncedCount ?? this.unsyncedCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

@riverpod
class VitalsNotifier extends _$VitalsNotifier {
  @override
  VitalsState build() {
    Future.microtask(() => load());
    return VitalsState.initial();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    try {
      final repo = ref.read(vitalsRepositoryProvider);

      await repo.ensureMockVitalsIfEmpty();

      final recent = await repo.fetchRecent(limit: 7);
      final unsynced = await repo.getUnsyncedVitals();

      state = state.copyWith(recent: recent, unsyncedCount: unsynced.length);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<int> addVital({
    required int heartRate,
    required int steps,
    required double sleepHours,
  }) async {
    final repo = ref.read(vitalsRepositoryProvider);

    // Network check
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasNetwork = connectivityResult != ConnectivityResult.none;

    final newVital = VitalEntity(
      id: null,
      heartRate: heartRate,
      steps: steps,
      sleepHours: sleepHours,
      createdAt: DateTime.now(),
      syncStatus: hasNetwork ? 1 : 0,
    );

    // Insert into DB
    final id = await repo.addVital(newVital);

    // If online → mark synced immediately
    if (hasNetwork) {
      await repo.markAsSynced(id);
    }

    // Re-fetch ONLY recent 7 items — prevents showing 8 items
    final recent = await repo.fetchRecent(limit: 7);

    final unsynced = await repo.getUnsyncedVitals();

    state = state.copyWith(recent: recent, unsyncedCount: unsynced.length);

    return id;
  }

  Future<void> markAsSynced(int id) async {
    final repo = ref.read(vitalsRepositoryProvider);
    await repo.markAsSynced(id);
    await load();
  }

  Future<void> refresh() => load();
}
