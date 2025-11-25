import 'dart:developer';

import 'package:dio/dio.dart';
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

  AuthRepositoryImpl(this._api);

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
}
