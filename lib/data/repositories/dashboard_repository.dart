import '../../models/dashboard_model.dart';
import '../../models/monthly_sales_model.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/erp_api_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._api);

  final ErpApiDataSource _api;

  @override
  Future<List<MonthlySalesModel>> getMonthlySales({int months = 12}) {
    return _api.getMonthlySalesNew(mons: months);
  }

  @override
  Future<DashboardModel> getManagementDashboard() {
    return _api.getManagementDashboardDataV2();
  }
}
