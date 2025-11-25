import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hubo/core/network/api_client.dart';
import 'package:hubo/core/db/app_database.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://68a5e0d92a3deed2960f3966.mockapi.io/api/v1/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // Attach token from local DB (if present) to every request.
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final token = await appDb.userDao.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (_) {
          // ignore DB errors; proceed without token
        }
        return handler.next(options);
      },
    ),
  );

  // Optional: add logging interceptor for debugging
  // dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.read(dioProvider);
  return ApiClient(dio);
});
