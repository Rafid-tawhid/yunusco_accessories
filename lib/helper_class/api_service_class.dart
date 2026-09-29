import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:yunusco_accessories/helper_class/helper_class.dart';
import 'package:yunusco_accessories/helper_class/user_data.dart';
import 'package:yunusco_accessories/models/requested_customer_details_model.dart';
import '../models/dashboard_model.dart';
import '../models/item_req_model.dart';
import '../models/item_req_detail_model.dart';
import '../models/monthly_sales_model.dart';
import '../models/user_model.dart';
import '../models/requested_customer_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    _initDio();
  }

  late Dio _dio;

  /// Base URL for all API calls
  //static const String baseUrl = 'http://192.168.5.4:8040/';
  static const String baseUrl = 'http://182.160.122.108:1010/';
  String? _sessionCookie; // store ASP.NET session cookie

  void _initDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // 🔹 Attach cookie if available
          if (_sessionCookie != null) {
            options.headers['Cookie'] = _sessionCookie;
          }
          debugPrint('➡️ [REQUEST] ${options.method} ${options.uri}');
          debugPrint('Headers: ${_redactForLog(options.headers)}');
          debugPrint('Data: ${_redactForLog(options.data)}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // 🔹 Extract cookie if login API returns it
          if (response.headers.map.containsKey('set-cookie')) {
            final cookies = response.headers.map['set-cookie']!;
            for (var cookie in cookies) {
              if (cookie.startsWith('ASP.NET_SessionId=')) {
                _sessionCookie = cookie.split(';').first;
                debugPrint('Session cookie received.');
              }
            }
          }

          debugPrint('✅ [RESPONSE] ${response.statusCode} -> ${_redactForLog(response.data)}',);
          return handler.next(response);
        },
        onError: (DioError error, handler) {
          debugPrint('❌ [ERROR] ${error.response?.statusCode} -> ${error.message}',);
          // Handle expired session (e.g., 401 or empty response)
          if (error.response?.statusCode == 401 || (error.response?.data == null && _sessionCookie != null)) {
            debugPrint('⚠️ Session expired, please login again.');
          }
          return handler.next(error);
        },
      ),
    );
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

  /// 🔹 Login API - stores session cookie
  Future<bool> loginUser(String email, String password) async {
    try {
      ApiService apiService = ApiService();

      var response = await apiService.post('Login/Login', {
        'LoginName': email,
        'Password': password,
      });
      if (response != null) {
        // Get cookie
        final cookies = response.headers['set-cookie'];

        if (cookies != null && cookies.isNotEmpty) {
          final sessionCookie = cookies.first;

          debugPrint('COOKIE => $sessionCookie');

          // Save cookie
          await DashboardHelper.saveSessionCookie(sessionCookie);
        }

        if (response.data['output'].toString() == "success") {
          UserData.user = UserModel.fromJson(response.data['rValue']);

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
        endpoint,
        queryParameters: query,
        options: Options(headers: {'Cookie': cookie}),
      );
      return response;
    } on DioError catch (e) {
      _handleError(e);
      return e.response;
    }
  }

  /// POST Request
  Future<Response?> post(
    String endpoint,
    dynamic data, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: query,
      );
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
      debugPrint(
        '⚠️ Server error: ${e.response?.statusCode} - ${e.response?.data}',
      );
    } else {
      debugPrint('🚫 Unexpected error: ${e.message}');
    }
  }

  /// 🔹 Get Requested Customers
  Future<List<RequestedCustomerModel>> getRequestedCustomers() async {
    try {
      //YTA_Requested_CustomerList_Confirmed_Mobile
      final response = await get(
        'Customers/YTA_Requested_CustomerList_Confirmed_Mobile',
      );
      if (response != null && response.statusCode == 200) {
        final List<dynamic> data = response.data is List
            ? response.data
            : (response.data['Data'] ?? []);
        return data
            .map((item) => RequestedCustomerModel.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching requested customers: $e');
      return [];
    }
  }

  Future<List<MonthlySalesModel>> getMonthlySalesNew({int mons = 12}) async {
    const String endpoint = 'http://182.160.122.108:1010/Home/MonthlySalesNew';

    try {
      final response = await http.get(Uri.parse('$endpoint?mons=$mons'));

      debugPrint('Response: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> rows = [];

        if (decoded is List) {
          rows = decoded;
        } else if (decoded is Map) {
          rows =
              decoded['Data'] ??
              decoded['data'] ??
              decoded['result'] ??
              decoded['Result'] ??
              [];
        }

        return rows.map((item) => MonthlySalesModel.fromJson(item)).toList();
      }

      debugPrint(
        'Failed to fetch monthly sales: ${response.statusCode} ${response.body}',
      );
      return [];
    } catch (e) {
      debugPrint('Error fetching monthly sales: $e');
      return [];
    }
  }

  Future<DashboardModel> getManagementDashboardDataV2() async {
    final response = await get('/Reporting/ManagementDashboardDataV2');
    if (response == null || response.statusCode != 200) {
      throw StateError(
        'Failed to load dashboard data'
        '${response?.statusCode == null ? '' : ' (${response!.statusCode})'}',
      );
    }

    dynamic payload = response.data;
    if (payload is Map) {
      final output = payload['output']?.toString().toLowerCase();
      if (output != null && output != 'success') {
        throw StateError(
          payload['msg']?.toString() ??
              payload['message']?.toString() ??
              'Dashboard data request failed',
        );
      }

      for (final key in [
        'rValue',
        'Data',
        'data',
        'result',
        'Result',
        'dashboardData',
        'DashboardData',
      ]) {
        final candidate = payload[key];
        if (candidate is Map) {
          payload = candidate;
          break;
        }
      }
    }

    if (payload is! Map) {
      throw const FormatException('Dashboard response must be an object');
    }
    return DashboardModel.fromJson(Map<String, dynamic>.from(payload));
  }

  Future<List<ItemReqModel>> getPendingMaterialRequisitionsNew() async {
    final response = await get('/HM/Order/GetPendingMaterialRequisitionsNew');
    if (response == null || response.statusCode != 200) {
      throw StateError(
        'Failed to load pending material requisitions'
        '${response?.statusCode == null ? '' : ' (${response!.statusCode})'}',
      );
    }

    final body = response.data;
    final dynamic rows = body is List
        ? body
        : body is Map
        ? body['data'] ?? body['Data']
        : null;
    if (rows is! List) {
      throw const FormatException(
        'Pending material requisitions response must contain a data list',
      );
    }

    return rows.map((row) {
      if (row is! Map) {
        throw const FormatException(
          'Pending material requisition entries must be objects',
        );
      }
      return ItemReqModel.fromJson(Map<String, dynamic>.from(row));
    }).toList();
  }

  final test={
    "output": "success",
    "msg": "Requisition fetched successfully.",
    "master": {
      "MaterialRequisitionMasterId": 1,
      "RequisitionNo": "MR-2026-0001",
      "RequisitionDate": "/Date(1790131387867)/",
      "Remarks": "From Item Purchase Add page",
      "TotalQuantity": 22000.0000,
      "Status": 1,
      "IsLocked": true,
      "CreatedBy": 1,
      "SubmittedBy": "Maruf Hossain",
      "CreatedDate": "/Date(1790131387867)/",
      "DecidedBy": "",
      "DecidedDate": null,
      "RejectReason": ""
    },
    "details": [
      {
        "MaterialRequisitionDetailsId": 1,
        "MaterialRequisitionMasterId": 1,
        "ItemId": "1",
        "ItemName": "TAG",
        "BuyerId": "101",
        "BuyerName": "",
        "Quantity": 2000.0000,
        "UnitId": "KG",
        "LineNo": 1,
        "CreatedByName": "Maruf Hossain",
        "Last6MonthsHistory": [
          {
            "MonthNo": 4,
            "YearNo": 2026,
            "Quantity": 0.0000
          },
          {
            "MonthNo": 5,
            "YearNo": 2026,
            "Quantity": 0.0000
          },
          {
            "MonthNo": 6,
            "YearNo": 2026,
            "Quantity": 0.0000
          },
          {
            "MonthNo": 7,
            "YearNo": 2026,
            "Quantity": 0.0000
          },
          {
            "MonthNo": 8,
            "YearNo": 2026,
            "Quantity": 0.0000
          },
          {
            "MonthNo": 9,
            "YearNo": 2026,
            "Quantity": 2000.0000
          }
        ]
      },
      {
        "MaterialRequisitionDetailsId": 2,
        "MaterialRequisitionMasterId": 1,
        "ItemId": "2",
        "ItemName": "TAG",
        "BuyerId": "102",
        "BuyerName": "KINGS & QUEENS",
        "Quantity": 15000.0000,
        "UnitId": "Sheet",
        "LineNo": 2,
        "CreatedByName": "Maruf Hossain",
        "Last6MonthsHistory": [
          {
            "MonthNo": 4,
            "YearNo": 2026,
            "Quantity": 0.0000
          },
          {
            "MonthNo": 5,
            "YearNo": 2026,
            "Quantity": 0.0000
          },
          {
            "MonthNo": 6,
            "YearNo": 2026,
            "Quantity": 0.0000
          },
          {
            "MonthNo": 7,
            "YearNo": 2026,
            "Quantity": 0.0000
          },
          {
            "MonthNo": 8,
            "YearNo": 2026,
            "Quantity": 0.0000
          },
          {
            "MonthNo": 9,
            "YearNo": 2026,
            "Quantity": 15000.0000
          }
        ]
      },
      {
        "MaterialRequisitionDetailsId": 3,
        "MaterialRequisitionMasterId": 1,
        "ItemId": "4",
        "ItemName": "STICKER",
        "BuyerId": "103",
        "BuyerName": "FRANKI",
        "Quantity": 5000.0000,
        "UnitId": "KG",
        "LineNo": 3,
        "CreatedByName": "Maruf Hossain",
        "Last6MonthsHistory": [
          {
            "MonthNo": 4,
            "YearNo": 2026,
            "Quantity": 0.0000
          },
          {
            "MonthNo": 5,
            "YearNo": 2026,
            "Quantity": 0.0000
          },
          {
            "MonthNo": 6,
            "YearNo": 2026,
            "Quantity": 0.0000
          },
          {
            "MonthNo": 7,
            "YearNo": 2026,
            "Quantity": 0.0000
          },
          {
            "MonthNo": 8,
            "YearNo": 2026,
            "Quantity": 0.0000
          },
          {
            "MonthNo": 9,
            "YearNo": 2026,
            "Quantity": 5000.0000
          }
        ]
      }
    ]
  };

  Future<ItemReqDetailModel> getManagementMaterialRequisition(num id) async {
    // final response = await get(
    //   '/HM/Order/GetManagementMaterialRequisition',
    //   query: {'id': id},
    // );
    // if (response == null || response.statusCode != 200) {
    //   throw StateError(
    //     'Failed to load requisition details'
    //     '${response?.statusCode == null ? '' : ' (${response!.statusCode})'}',
    //   );
    // }
    //
    // final body = response.data;
    // if (body is! Map || body['output']?.toString().toLowerCase() != 'success') {
    //   throw StateError(
    //     body is Map
    //         ? body['msg']?.toString() ?? 'Failed to load requisition details'
    //         : 'Invalid requisition response',
    //   );
    // }
    return ItemReqDetailModel.fromJson(Map<String, dynamic>.from(test));
  }

  Future<void> decideMaterialRequisition(ItemReqDecisionRequest request) async {
    final response = await post(
      '/HM/Order/DecideMaterialRequisition',
      request.toJson(),
    );
    if (response == null || response.statusCode != 200) {
      throw StateError(
        'Failed to ${request.decision.toLowerCase()} requisition'
        '${response?.statusCode == null ? '' : ' (${response!.statusCode})'}',
      );
    }

    final body = response.data;
    if (body is! Map || body['output']?.toString().toLowerCase() != 'success') {
      throw StateError(
        body is Map
            ? body['msg']?.toString() ?? 'Requisition decision failed'
            : 'Invalid requisition decision response',
      );
    }
  }

  Future<CustomerProfileDetailModel?> getCustomerProfileDetails(
    int customerId,
  ) async {
    try {
      final response = await get(
        'Customers/CustomerOutsideDetailsMobile?customerId=$customerId',
      );
      if (response != null && response.statusCode == 200) {
        final data = response.data is List
            ? response.data
            : (response.data['Data'] ?? []);
        return CustomerProfileDetailModel.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching requested customers: $e');
      return null;
    }
  }

  Future<bool> confirmCustomerProfile(int customerId, int acceptReject) async {
    try {
      final response = await post(
        'Customers/ConfirmOutsideCustomerProfileMobile',
        {'customerId': customerId, 'acceptReject': acceptReject},
      );
      if (response != null && response.statusCode == 200) {
        return response.data['output'] == 'success' ||
            response.data['Status'] == 'Success' ||
            response.data['output'] == 'Success';
      }
      return false;
    } catch (e) {
      debugPrint('Error confirming customer profile: $e');
      return false;
    }
  }

  static Future<dynamic> uploadChallanWithQR({
    required num userId,
    required String portal,
    required String challanId,
    required File imageFile,
    required bool isIdentified,
    required double qRMatchingPercentage,
  }) async {
    // First, make sure baseUrl is set
    String baseUrl =
        'http://182.160.122.108:1010/'; // REPLACE WITH YOUR SERVER IP

    debugPrint('🔍 Using baseUrl: $baseUrl');

    // Remove any trailing slashes if they exist
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    // Construct the full URL
    final apiUrl =
        'http://182.160.122.108:1010/DeliveryChallan/UPLOADCHALLANRECEVINGWITHQR';

    debugPrint('📤 Starting upload...');
    debugPrint('🔗 FULL API URL: $apiUrl');
    debugPrint(
      '📝 Params: userId=$userId, portal=$portal, challanId=$challanId',
    );
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
      request.fields['QRMatchingPercentage'] = qRMatchingPercentage
          .toStringAsFixed(2);
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
      if (responseData.contains('<!DOCTYPE html>') ||
          responseData.contains('<html>')) {
        debugPrint('❌ Received HTML error page instead of JSON');
        debugPrint(
          '💡 This means the API endpoint does not exist or URL is wrong',
        );
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
        String errorMessage =
            'Upload failed with status ${response.statusCode}';
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
