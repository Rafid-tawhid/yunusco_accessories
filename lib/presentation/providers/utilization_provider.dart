import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/utilization_list_model.dart';
import 'repository_providers.dart';


final confirmedUtilizationRequestsProvider = FutureProvider<List<UtilizationListModel>>((
  ref,
) async {
  return await ref
      .watch(utilizationRepositoryProvider)
      .getConfirmedUtilizationRequests();
});
