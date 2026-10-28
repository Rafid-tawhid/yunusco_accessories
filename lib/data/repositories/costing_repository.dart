import '../../models/costing_items.dart';
import '../../domain/repositories/costing_repository.dart';
import '../datasources/erp_api_data_source.dart';

class CostingRepositoryImpl implements CostingRepository {
  CostingRepositoryImpl(this._api);

  final ErpApiDataSource _api;

  @override
  Future<List<Map<String, dynamic>>> getRbos() async {
    final response = await _api.get('ItemPrice/RboHasItemVariablePrice');
    final data = response?.data;
    if (response?.statusCode != 200 || data is! List) return [];
    return List<Map<String, dynamic>>.from(data);
  }

  @override
  Future<List<Map<String, dynamic>>> getItemsForRbo(int rboId) async {
    final response = await _api.get(
      'ItemPrice/ItemsDdl',
      query: {'rboId': rboId},
    );
    final data = response?.data;
    if (data is! List) return [];
    return List<Map<String, dynamic>>.from(data);
  }

  @override
  Future<List<CostingItems>> getCostingItems(String itemRef) async {
    final response = await _api.get(
      'ItemPrice/Prices',
      query: {'ItemRef': itemRef},
    );
    if (response == null || response.statusCode != 200) {
      throw Exception('Failed to load costing items');
    }
    final data = response.data;
    if (data is! List) {
      throw const FormatException('Costing items response must be a list');
    }
    return data.map((item) => CostingItems.fromJson(item)).toList();
  }
}
