import '../datasources/erp_api_data_source.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._api);

  final ErpApiDataSource _api;

  @override
  Future<void> registerDeviceToken({
    required num userId,
    required num roleId,
    required String token,
  }) async {
    final response = await _api.post('api/user/CheckDeviceToken', {
      'roleId': roleId,
      'FirebaseDeviceToken': token,
      'Userid': userId,
    });
    final statusCode = response?.statusCode;
    if (statusCode == null || statusCode < 200 || statusCode >= 300) {
      throw StateError(
        'FCM token registration failed (HTTP ${statusCode ?? 'no response'}).',
      );
    }
  }
}
