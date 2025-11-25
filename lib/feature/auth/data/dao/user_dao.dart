import 'package:drift/drift.dart';
import 'package:hubo/core/db/app_database.dart';

import 'package:hubo/feature/auth/data/model/user_model.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [User])
class UserDao extends DatabaseAccessor<AppDb> with _$UserDaoMixin {
  final AppDb db;

  UserDao(this.db) : super(db);

  /// Inserts a new user into the database.
  ///
  /// Takes a [UsersCompanion] object representing the user to be added.
  ///
  /// Returns a [Future<int>] that completes with the ID of the inserted user.
  Future<int> addUser(UserCompanion user) =>
      into(db.user).insert(user, mode: InsertMode.insertOrReplace);

  /// Fetches the first user in the database.
  ///
  /// Returns a [Future<User?>] that completes with the first user or `null` if no user is found.
  Future<UserData?> getUser() {
    return select(db.user).getSingleOrNull();
  }

  /// Update the token for a user with [id]. Use `token == null` to clear it.
  Future<int> updateToken(int id, String? token) async {
    final companion = UserCompanion(token: Value(token));
    return (update(
      db.user,
    )..where((tbl) => tbl.id.equals(id))).write(companion);
  }

  /// Returns the stored token for the first user, or null if none.
  Future<String?> getToken() async {
    final user = await getUser();
    return user?.token;
  }

  /// Delete all users from the table (used for logout/clear data).
  Future<int> deleteAllUsers() async {
    return delete(db.user).go();
  }
}
