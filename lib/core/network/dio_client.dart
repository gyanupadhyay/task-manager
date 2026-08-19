import 'package:dio/dio.dart';

/// General-purpose HTTP client, registered in DI for any future REST needs.
/// Firestore/Auth traffic goes through their own SDKs, not this client.
Dio buildDioClient() {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  dio.interceptors.add(LogInterceptor(requestBody: false, responseBody: false));
  return dio;
}
