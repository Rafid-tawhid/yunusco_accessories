import '../../models/acessories_model.dart';
import '../../domain/repositories/accessory_repository.dart';
import '../datasources/firestore/accessory_data_source.dart';

class AccessoryRepositoryImpl implements AccessoryRepository {
  AccessoryRepositoryImpl(this._dataSource);

  final AccessoryDataSource _dataSource;

  @override
  Future<void> saveAccessory(GarmentAccessory accessory) {
    return _dataSource.saveAccessory(accessory);
  }

  @override
  Future<void> updateAccessory(GarmentAccessory accessory) {
    return _dataSource.updateAccessory(accessory);
  }

  @override
  Stream<List<GarmentAccessory>> watchAccessories() {
    return _dataSource.getAccessoriesStream();
  }
}
