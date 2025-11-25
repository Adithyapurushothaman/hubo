import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:hubo/feature/auth/data/dao/user_dao.dart';
import 'package:hubo/feature/auth/data/model/user_model.dart';
import 'package:hubo/feature/health/data/dao/vitals_dao.dart';
import 'package:hubo/feature/health/data/model/vital_model.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [User, Vitals], daos: [UserDao, VitalsDao])
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // If the DB was created with schemaVersion 1, add the `token`
      // column that was introduced in schema version 2.
      if (from < 2) {
        try {
          await m.addColumn(user, user.token);
        } catch (e) {
          // If adding column fails, log it — don't crash the app here.
          try {
            // ignore: avoid_print
            debugPrint('Failed to add token column during migration: $e');
          } catch (_) {}
        }
      }
    },
  );
}

/// A shared AppDb instance you can import from anywhere.
final appDb = AppDb();

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File('${dbFolder.path}/app.sqlite');

    return NativeDatabase.createInBackground(file);
  });
}
