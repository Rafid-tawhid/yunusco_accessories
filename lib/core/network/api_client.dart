import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers.remove('Cookie');
          final authorization = authorizationHeader;
          if (authorization != null) {
            options.headers['Authorization'] = authorization;
          }
          debugPrint('➡️ [REQUEST] ${options.method} ${options.uri}');
          debugPrint('Headers: ${_redactForLog(options.headers)}');
          debugPrint('Data: ${_redactForLog(options.data)}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
            '✅ [RESPONSE] ${response.statusCode} -> '
            '${_redactForLog(response.data)}',
          );
          handler.next(response);
        },
        onError: (error, handler) {
          debugPrint(
            '❌ [ERROR] ${error.response?.statusCode} -> ${error.message}',
          );
          if (error.response?.statusCode == 401) {
            debugPrint('⚠️ Session expired, please login again.');
          }
          handler.next(error);
        },
      ),
    );
  }

  static const String baseUrl = 'http://182.160.122.108:1010/';

  static final ApiClient instance = ApiClient._internal();

  late final Dio _dio;
  String? _accessToken;

  String? get authorizationHeader {
    final token = _accessToken?.trim();
    if (token == null || token.isEmpty) return null;
    return token.toLowerCase().startsWith('bearer ') ? token : 'Bearer $token';
  }

  Map<String, String> get authHeaders {
    final authorization = authorizationHeader;
    return authorization == null ? const {} : {'Authorization': authorization};
  }

  void setAccessToken(String? token) {
    _accessToken = token?.trim().isEmpty == true ? null : token?.trim();
  }

  Future<Response?> get(String endpoint, {Map<String, dynamic>? query}) async {
    try {
      return await _dio.get(endpoint, queryParameters: query);
    } on DioException catch (error) {
      _handleError(error);
      return error.response;
    }
  }

  Future<Response?> post(
    String endpoint,
    dynamic data, {
    Map<String, dynamic>? query,
  }) async {
    try {
      return await _dio.post(endpoint, data: data, queryParameters: query);
    } on DioException catch (error) {
      _handleError(error);
      return error.response;
    }
  }

  void _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout) {
      debugPrint('⏰ Connection timeout');
    } else if (error.type == DioExceptionType.receiveTimeout) {
      debugPrint('📶 Receive timeout');
    } else if (error.response != null) {
      debugPrint(
        '⚠️ Server error: ${error.response?.statusCode} - '
        '${_redactForLog(error.response?.data)}',
      );
    } else {
      debugPrint('🚫 Unexpected error: ${error.message}');
    }
  }

  Object? _redactForLog(Object? value) {
    if (value is Map) {
      return value.map((key, entryValue) {
        final normalizedKey = key.toString().toLowerCase();
        final isSensitive =
            normalizedKey.contains('token') ||
            normalizedKey.contains('password') ||
            normalizedKey.contains('cookie') ||
            normalizedKey.contains('authorization');
        return MapEntry(
          key,
          isSensitive ? '[REDACTED]' : _redactForLog(entryValue),
        );
      });
    }
    if (value is List) {
      return value.map(_redactForLog).toList();
    }
    return value;
  }
}
