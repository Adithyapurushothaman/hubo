import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hubo/feature/auth/domain/entities/user_entity.dart';
import 'package:hubo/feature/auth/data/providers.dart';
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
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.login(email, password);
      state = state.copyWith(user: user, isLoading: false, error: null);
      return user;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void logout() {
    state = AuthState.initial();
  }
}
