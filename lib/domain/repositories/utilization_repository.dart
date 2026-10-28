import 'package:yunusco_accessories/models/utilization_list_model.dart';

abstract interface class UtilizationRepository {
  Future<List<UtilizationListModel>> getConfirmedUtilizationRequests();
}