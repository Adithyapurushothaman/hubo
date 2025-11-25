import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hubo/core/network/providers.dart';
import 'package:hubo/feature/auth/data/api/auth_api.dart';
import 'package:hubo/feature/auth/data/repositories/auth_repository_impl.dart';
import 'package:hubo/feature/auth/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.read(apiClientProvider);
  final api = AuthApi(client);
  return AuthRepositoryImpl(api);
});
