import 'package:drift/drift.dart';

class User extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get email => text().unique()();
  TextColumn get password => text()();
  // Store the auth token returned by the backend. Nullable when not logged in.
  TextColumn get token => text().nullable()();
}
