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
  static const String baseUrl = 'http://192.168.5.4:8030/';
  String? _sessionCookie; // store ASP.NET session cookie

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
        // 🔹 Attach cookie if available
        if (_sessionCookie != null) {
          options.headers['Cookie'] = _sessionCookie;
        }

        debugPrint('➡️ [REQUEST] ${options.method} ${options.uri}');
        debugPrint('Headers: ${options.headers}');
        debugPrint('Data: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // 🔹 Extract cookie if login API returns it
        if (response.headers.map.containsKey('set-cookie')) {
          final cookies = response.headers.map['set-cookie']!;
          for (var cookie in cookies) {
            if (cookie.startsWith('ASP.NET_SessionId=')) {
              _sessionCookie = cookie.split(';').first;
              debugPrint('🍪 New Session Cookie: $_sessionCookie');
            }
          }
        }

        debugPrint('✅ [RESPONSE] ${response.statusCode} -> ${response.data}');
        return handler.next(response);
      },
      onError: (DioError error, handler) {
        debugPrint('❌ [ERROR] ${error.response?.statusCode} -> ${error.message}');
        // Handle expired session (e.g., 401 or empty response)
        if (error.response?.statusCode == 401 ||
            (error.response?.data == null &&
                _sessionCookie != null)) {
          debugPrint('⚠️ Session expired, please login again.');
        }
        return handler.next(error);
      },
    ));
  }

  /// 🔹 Login API - stores session cookie
  Future<bool> login(String username, String password) async {
    try {
      final response = await _dio.post(
        'Login/Login',
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
        data: FormData.fromMap({
          'LoginName': username,
          'Password': password,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Login Successful');
        return true;
      } else {
        debugPrint('⚠️ Login Failed: ${response.statusCode}');

        return false;
      }
    } on DioError catch (e) {
      _handleError(e);
      return false;
    }
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
      final response =
      await _dio.post(endpoint, data: data, queryParameters: query);
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

  /// Optional: Manually set cookie (if known)
  void setCookie(String cookie) {
    _sessionCookie = cookie;
    debugPrint('🍪 Manually set cookie: $_sessionCookie');
  }

  /// Optional: Clear cookie on logout
  void clearCookie() {
    _sessionCookie = null;
    debugPrint('🚪 Session cleared');
  }
}
