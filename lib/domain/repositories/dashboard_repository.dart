import '../../models/dashboard_model.dart';
import '../../models/monthly_sales_model.dart';

abstract interface class DashboardRepository {
  Future<List<MonthlySalesModel>> getMonthlySales({int months = 12});

  Future<DashboardModel> getManagementDashboard();
}
