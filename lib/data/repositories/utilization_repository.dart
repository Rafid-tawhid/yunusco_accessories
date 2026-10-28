import 'package:yunusco_accessories/domain/repositories/utilization_repository.dart';
import 'package:yunusco_accessories/models/utilization_list_model.dart';
import '../datasources/erp_api_data_source.dart';

class UtilizationRepositoryImpl implements UtilizationRepository {
  UtilizationRepositoryImpl(this._api);
  final ErpApiDataSource _api;

  @override
  Future<List<UtilizationListModel>> getConfirmedUtilizationRequests() {

    return _api.getConfirmedUtilizationRequests();
  }
}