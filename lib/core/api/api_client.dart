// core/api/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api_interceptor.dart';

class APIClient {
  static final APIClient _instance = APIClient._internal();
  factory APIClient() => _instance;

  late final Dio _dio;

  APIClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['API_BASE_URL'] ?? 'https://api.ipot.dev',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([LoggingInterceptor(), RetryInterceptor(_dio)]);
  }

  Dio get dio => _dio;
}
