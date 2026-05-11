import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:yunusco_accessories/helper_class/helper_class.dart';
import 'package:yunusco_accessories/helper_class/user_data.dart';

import '../models/user_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    _initDio();
  }

  late Dio _dio;

  /// Base URL for all API calls
  // static const String baseUrl = 'http://192.168.5.4:8030/';
  static const String baseUrl = 'http://182.160.122.108:1010/';
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
  Future<bool> loginUser(String email, String password) async {
    try {
      ApiService apiService = ApiService();

      var response = await apiService.post(
        'Login/Login',
        {
          'LoginName': email,
          'Password': password,
        },
      );
      if(response!=null){
        // Get cookie
        final cookies = response.headers['set-cookie'];

        if (cookies != null && cookies.isNotEmpty) {

          final sessionCookie = cookies.first;

          debugPrint('COOKIE => $sessionCookie');

          // Save cookie
          await DashboardHelper.saveSessionCookie(
            sessionCookie,
          );
        }

        if (response.data['output'].toString() == "success") {

          UserData.user = UserModel.fromJson(
            response.data['rValue'],
          );

          return true;

        }
      }
      return false;

    } catch (e) {
      return false;
    }
  }

  /// GET Request
  Future<Response?> get(String endpoint, {Map<String, dynamic>? query}) async {
    try {
      final cookie = await DashboardHelper.getSessionCookie();
      final response = await _dio.get(
          endpoint, queryParameters: query,
          options: Options(
            headers: {
              'Cookie': cookie,
            },
          ),
      );
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




  static Future<dynamic> uploadChallanWithQR({
    required num userId,
    required String portal,
    required String challanId,
    required File imageFile,
    required bool isIdentified,
    required double qRMatchingPercentage
  }) async {

    // First, make sure baseUrl is set
    String baseUrl = 'http://182.160.122.108:1010/'; // REPLACE WITH YOUR SERVER IP

    debugPrint('🔍 Using baseUrl: $baseUrl');

    // Remove any trailing slashes if they exist
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    // Construct the full URL
    final apiUrl = 'http://182.160.122.108:1010/DeliveryChallan/UPLOADCHALLANRECEVINGWITHQR';

    debugPrint('📤 Starting upload...');
    debugPrint('🔗 FULL API URL: $apiUrl');
    debugPrint('📝 Params: userId=$userId, portal=$portal, challanId=$challanId');
    debugPrint('📸 File path: ${imageFile.path}');

    try {
      // Test if we can reach the server first
      debugPrint('🔍 Testing server connection...');
      try {
        var testResponse = await http.get(Uri.parse('$baseUrl/'));
        debugPrint('✅ Server reachable: ${testResponse.statusCode}');
      } catch (e) {
        debugPrint('❌ Cannot reach server: $e');
        debugPrint('💡 Tip: Make sure server is running and URL is correct');
      }

      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Add headers if needed
      request.headers['Accept'] = 'application/json';

      // Add fields
      request.fields['userId'] = userId.toString();
      request.fields['portal'] = portal;
      request.fields['challanId'] = challanId.toString();
      request.fields['isIdentified'] = isIdentified.toString();
      request.fields['QRMatchingPercentage'] = qRMatchingPercentage.toStringAsFixed(2);
      debugPrint('📦 Request fields: ${request.fields}');

      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          filename: 'challan_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );

      debugPrint('🚀 Sending request to: $apiUrl');
      var response = await request.send();

      debugPrint('📥 Response status: ${response.statusCode}');

      var responseData = await response.stream.bytesToString();
      debugPrint('📄 Response length: ${responseData.length} characters');

      // Check if response is HTML error page
      if (responseData.contains('<!DOCTYPE html>') || responseData.contains('<html>')) {
        debugPrint('❌ Received HTML error page instead of JSON');
        debugPrint('💡 This means the API endpoint does not exist or URL is wrong');
        debugPrint('💡 Please check:');
        debugPrint('   1. Is the server running?');
        debugPrint('   2. Is the API endpoint path correct?');
        debugPrint('   3. Can you access $apiUrl from browser?');
      }

      if (response.statusCode == 200) {
        try {
          var jsonResponse = jsonDecode(responseData);
          debugPrint('✅ Success! Response: $jsonResponse');

          return jsonResponse;
        } catch (e) {
          debugPrint('⚠️ Status 200 but JSON parse failed: $e');
          return e.toString();
        }
      } else {
        debugPrint('❌ Upload failed with status ${response.statusCode}');

        // Try to extract error message
        String errorMessage = 'Upload failed with status ${response.statusCode}';
        if (responseData.contains('The resource cannot be found')) {
          errorMessage = 'API endpoint not found. Check URL: $apiUrl';
        }

        return response;
      }

    } catch (e, stackTrace) {
      debugPrint('❌ Exception occurred: $e');
      debugPrint('Stack trace: $stackTrace');

      return e;
    }
  }
}
