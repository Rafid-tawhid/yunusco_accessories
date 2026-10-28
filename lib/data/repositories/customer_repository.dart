import '../../models/requested_customer_details_model.dart';
import '../../models/requested_customer_model.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/erp_api_data_source.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  CustomerRepositoryImpl(this._api);

  final ErpApiDataSource _api;

  @override
  Future<List<RequestedCustomerModel>> getRequestedCustomers() {
    return _api.getRequestedCustomers();
  }

  @override
  Future<CustomerProfileDetailModel?> getCustomerProfileDetails(
    int customerId,
  ) {
    return _api.getCustomerProfileDetails(customerId);
  }

  @override
  Future<bool> confirmCustomerProfile(int customerId, int acceptReject) {
    return _api.confirmCustomerProfile(customerId, acceptReject);
  }
}
