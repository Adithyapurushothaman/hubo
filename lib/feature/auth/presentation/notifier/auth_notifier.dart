import 'package:hubo/core/provider/global_provider.dart';
import 'package:hubo/feature/health/data/providers.dart';
import 'package:hubo/feature/health/domain/entities/vital_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:hubo/feature/auth/domain/entities/user_entity.dart';
import 'package:hubo/core/db/app_database.dart';
import 'package:drift/drift.dart';
part 'auth_notifier.g.dart';

class AuthState {
  const AuthState({this.user, required this.isLoading, this.error});

  final UserEntity? user;
  final bool isLoading;
  final String? error;

  factory AuthState.initial() =>
      const AuthState(user: null, isLoading: false, error: null);

  AuthState copyWith({UserEntity? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    return AuthState.initial();
  }

  Future<UserEntity> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final vitalRepo = ref.read(vitalsRepositoryProvider);
      final user = await authRepo.login(email, password);
      // persist token in local DB for auth status checks
      try {
        final existing = await authRepo.getUser();
        if (existing != null) {
          await authRepo.saveToken(existing.email, user.token!);
        } else {
          final companion = UserCompanion.insert(
            email: user.email,
            password: '',
            token: Value(user.token),
          );
          await vitalRepo.insertMockVitals();
          final id = await authRepo.addUser(companion);
          try {
            // ignore: avoid_print
            debugPrint('Inserted user id: $id');
          } catch (_) {}
        }
      } catch (ex, st) {
        // Log DB exceptions so we can diagnose why persistence failed.
        // Avoid crashing the app; auth still succeeds.
        try {
          // ignore: avoid_print
          debugPrint('AppDb persistence error during login: $ex');
          // ignore: avoid_print
          debugPrint('$st');
        } catch (_) {}
      }
      // The provider may have been disposed while awaiting async work.
      // Avoid using `state` (which accesses `ref`) when disposed.
      if (ref.mounted) {
        state = state.copyWith(user: user, isLoading: false, error: null);
      }
      return user;
    } catch (e) {
      if (ref.mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
      rethrow;
    }
  }

  Future<UserEntity> signup(
    String username,
    String email,
    String password,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.signup(username, email, password);

      // persist token in local DB for auth status checks
      try {
        final existing = await repo.getUser();
        if (existing != null) {
          await repo.saveToken(existing.email, user.token!);
        } else {
          final companion = UserCompanion.insert(
            email: user.email,
            password: '',
            token: Value(user.token),
          );
          final id = await repo.addUser(companion);
          try {
            // ignore: avoid_print
            debugPrint('Inserted user id: $id');
          } catch (_) {}
        }
      } catch (ex, st) {
        try {
          // ignore: avoid_print
          debugPrint('AppDb persistence error during signup: $ex');
          // ignore: avoid_print
          debugPrint('$st');
        } catch (_) {}
      }

      if (ref.mounted) {
        state = state.copyWith(user: user, isLoading: false, error: null);
      }
      return user;
    } catch (e) {
      if (ref.mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
      rethrow;
    }
  }

  void logout() {
    // Clear persisted user data from the local DB as part of logout.
    // Don't await here to avoid blocking the UI event; run async and
    // update state when complete.
    () async {
      try {
        final authRepo = ref.read(authRepositoryProvider);
        final vitalRepo = ref.read(vitalsRepositoryProvider);
        await vitalRepo.clearAllVitals();
        await authRepo.clearUser();
      } catch (e) {
        try {
          // ignore: avoid_print
          debugPrint('Error clearing user data during logout: $e');
        } catch (_) {}
      }
      if (ref.mounted) {
        state = AuthState.initial();
      }
    }();
  }
}
