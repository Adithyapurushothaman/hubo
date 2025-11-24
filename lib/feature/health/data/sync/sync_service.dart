import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:hubo/feature/health/domain/repositories/vitals_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hubo/feature/health/data/providers.dart';
// vitals dao removal: SyncService now depends on VitalsRepository

/// SyncService listens to connectivity changes and attempts to upload
/// unsynced vitals to a mock backend, marking them as synced on success.
class SyncService {
  final VitalsRepository repo;
  final Dio _dio;
  // Use a dynamic subscription type because `onConnectivityChanged`
  // may return `Stream<ConnectivityResult>` or `Stream<List<ConnectivityResult>>`
  // depending on platform/plugin version. We handle both cases below.
  StreamSubscription<dynamic>? _sub;

  SyncService(this.repo) : _dio = Dio();

  void start() {
    // Immediately try once if connected
    Connectivity().checkConnectivity().then((result) {
      if (result != ConnectivityResult.none) _syncPending();
    });

    // Listen for connectivity changes. The plugin emits a single
    // ConnectivityResult on most platforms; respond when it's not `none`.
    _sub = Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        _syncPending();
      }
    });
  }

  void stop() {
    _sub?.cancel();
  }

  Future<void> _syncPending() async {
    final pending = await repo.getUnsyncedVitals();
    if (pending.isEmpty) return;

    for (final row in pending) {
      try {
        final payload = {
          'heart_rate': row.heartRate,
          'steps': row.steps,
          'sleep_hours': row.sleepHours,
          'created_at': row.createdAt.toIso8601String(),
        };

        // Use httpbin.org/post as a mock endpoint that echoes back
        final res = await _dio.post('https://httpbin.org/post', data: payload);
        if (res.statusCode == 200 || res.statusCode == 201) {
          await repo.markAsSynced(row.id!);
        }
      } catch (e) {
        // If one fails, continue with others; we'll retry later.
        // You could add exponential backoff here.
      }
    }
  }
}

/// Riverpod provider that manages the lifecycle of [SyncService].
/// It will start the service when the provider is created and stop it on dispose.
final syncServiceProvider = Provider<SyncService>((ref) {
  final repo = ref.watch(vitalsRepositoryProvider);
  final service = SyncService(repo);
  service.start();
  ref.onDispose(() {
    service.stop();
  });
  return service;
});
