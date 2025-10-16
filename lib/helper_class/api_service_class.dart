import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    _initDio();
  }

  late Dio _dio;

  /// Base URL for all API calls
  static const String baseUrl = 'http://202.74.243.118:8090/';

  void _initDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint('➡️ [REQUEST] ${options.method} ${options.uri}');
        debugPrint('Headers: ${options.headers}');
        debugPrint('Data: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('✅ [RESPONSE] ${response.statusCode} -> ${response.data}');
        return handler.next(response);
      },
      onError: (DioError error, handler) {
        debugPrint('❌ [ERROR] ${error.response?.statusCode} -> ${error.message}');
        return handler.next(error);
      },
    ));
  }

  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// GET Request
  Future<Response?> get(String endpoint, {Map<String, dynamic>? query}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: query);
      return response;
    } on DioError catch (e) {
      _handleError(e);
      return e.response;
    }
  }

  /// POST Request
  Future<Response?> post(String endpoint, dynamic data,
      {Map<String, dynamic>? query}) async {
    try {
      final response = await _dio.post(endpoint, data: data, queryParameters: query);
      return response;
    } on DioError catch (e) {
      _handleError(e);
      return e.response;
    }
  }

  /// PUT Request
  Future<Response?> put(String endpoint, dynamic data) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response;
    } on DioError catch (e) {
      _handleError(e);
      return e.response;
    }
  }

  /// DELETE Request
  Future<Response?> delete(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.delete(endpoint, data: data);
      return response;
    } on DioError catch (e) {
      _handleError(e);
      return e.response;
    }
  }

  /// Common error handler
  void _handleError(DioError e) {
    if (e.type == DioErrorType.connectionTimeout) {
      debugPrint('⏰ Connection timeout');
    } else if (e.type == DioErrorType.receiveTimeout) {
      debugPrint('📶 Receive timeout');
    } else if (e.response != null) {
      debugPrint('⚠️ Server error: ${e.response?.statusCode} - ${e.response?.data}');
    } else {
      debugPrint('🚫 Unexpected error: ${e.message}');
    }
  }
}
