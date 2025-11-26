import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:hubo/core/db/app_database.dart';
import 'package:hubo/feature/auth/data/api/auth_api.dart';
import 'package:hubo/feature/auth/domain/entities/user_entity.dart';
import 'package:hubo/feature/auth/domain/repositories/auth_repository.dart';

/// Dio-based implementation of [AuthRepository].
///
/// Posts credentials to a remote endpoint and returns a [UserEntity]
/// constructed from the response. Errors are rethrown as [DioException]
/// or generic [Exception].
class AuthRepositoryImpl implements AuthRepository {
  final AuthApi _api;
  final AppDb db;

  AuthRepositoryImpl(this._api, this.db);

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      final resp = await _api.login(email, password);

      log('Auth login response: status=${resp.statusCode} data=${resp.data}');

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = resp.data;
        // Try to extract common fields from the response.
        int? id;
        String? token;
        String returnedEmail = email;

        if (data is Map) {
          if (data['id'] != null) {
            id = int.tryParse('${data['id']}');
          }
          if (data['token'] != null) token = '${data['token']}';
          // Accept multiple possible email keys returned by different APIs
          returnedEmail =
              (data['email'] ?? data['emailid'] ?? data['username'] ?? email)
                  .toString();
        }

        return UserEntity(id: id, email: returnedEmail, token: token);
      }

      throw Exception('Login failed with status ${resp.statusCode}');
    } on DioException catch (e) {
      // Log and rethrow so callers can handle display or retry logic.
      log('DioException during login: ${e.message}');
      rethrow;
    } catch (e) {
      log('Unexpected error during login: $e');
      rethrow;
    }
  }

  @override
  Future<UserEntity> signup(
    String username,
    String email,
    String password,
  ) async {
    try {
      final resp = await _api.signup(username, email, password);

      log('Auth signup response: status=${resp.statusCode} data=${resp.data}');

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = resp.data;
        int? id;
        String? token;
        String returnedEmail = email;

        if (data is Map) {
          if (data['id'] != null) {
            id = int.tryParse('${data['id']}');
          }
          if (data['token'] != null) token = '${data['token']}';
          // Accept multiple possible email keys returned by different APIs
          returnedEmail =
              (data['email'] ?? data['emailid'] ?? data['username'] ?? email)
                  .toString();
        }

        return UserEntity(id: id, email: returnedEmail, token: token);
      }

      throw Exception('Signup failed with status ${resp.statusCode}');
    } on DioException catch (e) {
      log('DioError during signup: ${e.message}');
      rethrow;
    } catch (e) {
      log('Unexpected error during signup: $e');
      rethrow;
    }
  }

  @override
  Future<String?> getToken() {
    return db.userDao.getToken();
  }

  @override
  Future<void> clearUser() async {
    await db.userDao.deleteAllUsers();
  }

  @override
  Future<int> saveToken(String email, String token) async {
    final existing = await db.userDao.getUser();

    if (existing != null) {
      return db.userDao.updateToken(existing.id!, token);
    } else {
      final companion = UserCompanion.insert(
        email: email,
        password: '',
        token: Value(token),
      );
      return db.userDao.addUser(companion);
    }
  }

  @override
  Future<UserEntity?> getUser() async {
    final userData = await db.userDao.getUser();
    if (userData == null) return null;

    return UserEntity(
      id: userData.id,
      email: userData.email,
      token: userData.token,
    );
  }

  @override
  Future<int> addUser(UserCompanion user) {
    return db.userDao.addUser(user);
  }
}
