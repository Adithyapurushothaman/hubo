import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:hubo/feature/auth/data/dao/user_dao.dart';
import 'package:hubo/feature/auth/data/model/user_model.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [User], daos: [UserDao])
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File('${dbFolder.path}/app.sqlite');

    return NativeDatabase.createInBackground(file);
  });
}
