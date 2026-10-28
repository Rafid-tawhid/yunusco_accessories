import 'dart:io';

import '../../domain/repositories/challan_repository.dart';
import '../datasources/erp_api_data_source.dart';

class ChallanRepositoryImpl implements ChallanRepository {
  @override
  Future<dynamic> uploadWithQr({
    required num userId,
    required String portal,
    required String challanId,
    required File imageFile,
    required bool isIdentified,
    required double qrMatchingPercentage,
  }) {
    return ErpApiDataSource.uploadChallanWithQR(
      userId: userId,
      portal: portal,
      challanId: challanId,
      imageFile: imageFile,
      isIdentified: isIdentified,
      qRMatchingPercentage: qrMatchingPercentage,
    );
  }
}
