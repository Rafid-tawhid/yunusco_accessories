import '../../models/requested_customer_details_model.dart';
import '../../models/requested_customer_model.dart';

abstract interface class CustomerRepository {
  Future<List<RequestedCustomerModel>> getRequestedCustomers();

  Future<CustomerProfileDetailModel?> getCustomerProfileDetails(int customerId);

  Future<bool> confirmCustomerProfile(int customerId, int acceptReject);
}
