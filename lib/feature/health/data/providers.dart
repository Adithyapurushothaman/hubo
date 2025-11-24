import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hubo/feature/health/data/repositories/vitals_repository_impl.dart';
import 'package:hubo/feature/health/domain/repositories/vitals_repository.dart';
import 'package:hubo/core/db/app_database.dart';

final vitalsRepositoryProvider = Provider<VitalsRepository>((ref) {
  // Use the shared AppDb instance. In tests, override this provider.
  return VitalsRepositoryImpl(appDb);
});
