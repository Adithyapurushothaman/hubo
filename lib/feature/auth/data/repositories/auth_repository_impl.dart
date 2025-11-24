import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:hubo/feature/auth/domain/entities/user_entity.dart';
import 'package:hubo/feature/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  AuthRepositoryImpl(this._dio);

  static const _loginUrl =
      'https://68a5e0d92a3deed2960f3966.mockapi.io/api/v1/login';

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      final resp = await _dio.post(
        _loginUrl,
        data: {'email': email, 'password': password},
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = resp.data;
        // Mock APIs often echo back the payload or return an id/token.
        final id = (data is Map && data['id'] != null)
            ? int.tryParse('${data['id']}')
            : null;
        final token = (data is Map && data['token'] != null)
            ? '${data['token']}'
            : null;
        final returnedEmail = (data is Map && data['email'] != null)
            ? '${data['email']}'
            : email;
        return UserEntity(id: id, email: returnedEmail, token: token);
      }

      throw Exception('Login failed: ${resp.statusCode}');
    } on DioError catch (e) {
      log('Login request failed: ${e.message}');
      rethrow;
    }
  }
}
