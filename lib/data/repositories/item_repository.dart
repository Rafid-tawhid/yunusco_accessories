import '../../models/item_req_detail_model.dart';
import '../../models/item_req_model.dart';
import '../../models/items_model.dart';
import '../../domain/repositories/item_repository.dart';
import '../datasources/erp_api_data_source.dart';

class ItemRepositoryImpl implements ItemRepository {
  ItemRepositoryImpl(this._api);

  final ErpApiDataSource _api;

  @override
  Future<List<ItemsModel>> getItems() async {
    final response = await _api.get(
      'Priceing/GetNewItem',
      query: {'searchText': ''},
    );
    if (response == null || response.statusCode != 200) return [];
    final data = response.data;
    if (data is! List) return [];
    return data.map((item) => ItemsModel.fromJson(item)).toList();
  }

  @override
  Future<List<ItemReqModel>> getPendingMaterialRequisitions() {
    return _api.getPendingMaterialRequisitionsNew();
  }

  @override
  Future<ItemReqDetailModel> getMaterialRequisitionDetails(num id) {
    return _api.getManagementMaterialRequisition(id);
  }

  @override
  Future<void> decideMaterialRequisition(ItemReqDecisionRequest request) {
    return _api.decideMaterialRequisition(request);
  }


}
