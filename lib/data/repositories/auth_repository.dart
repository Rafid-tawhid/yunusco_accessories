import '../../core/network/api_client.dart';
import '../../core/session/user_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../models/user_model.dart';
import '../datasources/erp_api_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._api);

  final ErpApiDataSource _api;

  @override
  Future<LoginResult> login(String username, String password) async {
    ApiClient.instance.setAccessToken(null);
    final response = await _api.post('Login/Login', {
      'LoginName': username,
      'Password': password,
    });

    final body = response?.data;
    if (body is! Map || body['output'].toString() != 'success') {
      final message = body is Map
          ? body['message']?.toString() ?? body['msg']?.toString()
          : null;
      return LoginResult.failure(message);
    }

    final userData = body['rValue'];
    if (userData is! Map) {
      return LoginResult.failure('Login response is missing user data');
    }

    final token = body['token'] ?? userData['token'];
    if (token != null && token.toString().trim().isNotEmpty) {
      ApiClient.instance.setAccessToken(token.toString());
    }
    UserSession.user = UserModel.fromJson(userData);
    return LoginResult.success();
  }
}
