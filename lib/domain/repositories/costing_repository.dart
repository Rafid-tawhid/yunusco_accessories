import '../../models/costing_items.dart';

abstract interface class CostingRepository {
  Future<List<Map<String, dynamic>>> getRbos();

  Future<List<Map<String, dynamic>>> getItemsForRbo(int rboId);

  Future<List<CostingItems>> getCostingItems(String itemRef);
}
