abstract interface class NotificationRepository {
  Future<void> registerDeviceToken({
    required num userId,
    required num roleId,
    required String token,
  });
}
