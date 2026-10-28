import '../../models/item_req_detail_model.dart';
import '../../models/item_req_model.dart';
import '../../models/items_model.dart';

abstract interface class ItemRepository {
  Future<List<ItemsModel>> getItems();

  Future<List<ItemReqModel>> getPendingMaterialRequisitions();

  Future<ItemReqDetailModel> getMaterialRequisitionDetails(num id);

  Future<void> decideMaterialRequisition(ItemReqDecisionRequest request);


}
