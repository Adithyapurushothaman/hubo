import 'package:hubo/feature/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  /// Attempts to login with [email] and [password].
  /// Returns the authenticated [UserEntity] on success.
  Future<UserEntity> login(String email, String password);

  /// Attempts to create a new user with [username], [email] and [password].
  /// Returns the created [UserEntity] on success.
  Future<UserEntity> signup(String username, String email, String password);
}
