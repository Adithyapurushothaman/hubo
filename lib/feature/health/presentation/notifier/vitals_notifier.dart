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
    final initial = VitalsState.initial();
    // trigger async load after build
    Future.microtask(() => load());
    return initial;
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

  // Future<int> addVital({
  //   required int heartRate,
  //   required int steps,
  //   required double sleepHours,
  // }) async {
  //   final entity = VitalEntity(
  //     id: null,
  //     heartRate: heartRate,
  //     steps: steps,
  //     sleepHours: sleepHours,
  //     createdAt: DateTime.now(),
  //     syncStatus: 0,
  //   );

  //   final repo = ref.read(vitalsRepositoryProvider);
  //   final id = await repo.addVital(entity);
  //   await load();
  //   return id;
  // }
  Future<int> addVital({
    required int heartRate,
    required int steps,
    required double sleepHours,
  }) async {
    final repo = ref.read(vitalsRepositoryProvider);

    final entity = VitalEntity(
      id: null,
      heartRate: heartRate,
      steps: steps,
      sleepHours: sleepHours,
      createdAt: DateTime.now(),
      syncStatus: 0,
    );

    final id = await repo.addVital(entity);

    // Insert new entity immediately into UI state
    final updated = VitalEntity(
      id: id,
      heartRate: heartRate,
      steps: steps,
      sleepHours: sleepHours,
      createdAt: entity.createdAt,
      syncStatus: 0,
    );

    state = state.copyWith(
      recent: [updated, ...state.recent], // Prepend newest
      unsyncedCount: state.unsyncedCount + 1,
    );

    return id;
  }

  Future<void> markAsSynced(int id) async {
    final repo = ref.read(vitalsRepositoryProvider);
    await repo.markAsSynced(id);
    await load();
  }

  Future<void> refresh() => load();
}
