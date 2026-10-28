import 'dart:io';

abstract interface class ChallanRepository {
  Future<dynamic> uploadWithQr({
    required num userId,
    required String portal,
    required String challanId,
    required File imageFile,
    required bool isIdentified,
    required double qrMatchingPercentage,
  });
}
