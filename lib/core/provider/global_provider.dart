import 'package:hubo/core/db/app_database.dart';
import 'package:hubo/core/network/api_client.dart';
import 'package:hubo/core/network/providers.dart';
import 'package:hubo/feature/auth/data/api/auth_api.dart';
import 'package:hubo/feature/auth/data/repositories/auth_repository_impl.dart';
import 'package:hubo/feature/auth/domain/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'global_provider.g.dart';

/// Provides a single shared Drift database instance.
@Riverpod(keepAlive: true)
AppDb appDatabase(Ref ref) {
  final db = AppDb();

  // Automatically close DB when provider is destroyed (rare due to keepAlive).
  ref.onDispose(() {
    db.close();
  });

  return db;
}

@riverpod
AuthRepository authRepository(Ref ref) {
  final client = ref.watch(apiClientProvider);
  final api = AuthApi(client);
  final db = ref.read(appDatabaseProvider);
  return AuthRepositoryImpl(api, db);
}
