import '../../models/acessories_model.dart';

abstract interface class AccessoryRepository {
  Future<void> saveAccessory(GarmentAccessory accessory);

  Future<void> updateAccessory(GarmentAccessory accessory);

  Stream<List<GarmentAccessory>> watchAccessories();
}
