import 'package:dio/dio.dart';
import 'package:hubo/core/network/api_client.dart';

/// Small API wrapper for auth-related network calls.
class AuthApi {
  final ApiClient _client;

  AuthApi(this._client);

  /// Sends login credentials to the remote endpoint and returns the Dio [Response].
  Future<Response<dynamic>> login(String email, String password) {
    return _client.post('login', data: {'email': email, 'password': password});
  }

  /// Sends signup data to the remote endpoint and returns the Dio [Response].
  Future<Response<dynamic>> signup(
    String username,
    String email,
    String password,
  ) {
    return _client.post(
      'signup',
      data: {'username': username, 'email': email, 'password': password},
    );
  }
}
