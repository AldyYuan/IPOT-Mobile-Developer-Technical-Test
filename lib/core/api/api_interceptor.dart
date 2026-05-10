import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('[REQ] ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('[RES] ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('[ERR] ${err.type} — ${err.message}');
    handler.next(err);
  }
}

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;

  RetryInterceptor(this.dio, {this.maxRetries = 2});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final attempt = err.requestOptions.extra['retryCount'] ?? 0;

    final shouldRetry =
        attempt < maxRetries && err.type == DioExceptionType.connectionTimeout;

    if (shouldRetry) {
      err.requestOptions.extra['retryCount'] = attempt + 1;
      await Future.delayed(Duration(seconds: attempt + 1)); // backoff
      try {
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        debugPrint('[ERR] Retry failed: $e');
        // fall through to next handler
      }
    }

    handler.next(err);
  }
}
