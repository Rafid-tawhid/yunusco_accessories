import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yunusco_accessories/domain/repositories/utilization_repository.dart';

import '../../data/datasources/erp_api_data_source.dart';
import '../../data/datasources/firestore/accessory_data_source.dart';
import '../../data/repositories/accessory_repository.dart' as data;
import '../../data/repositories/auth_repository.dart' as data;
import '../../data/repositories/challan_repository.dart' as data;
import '../../data/repositories/costing_repository.dart' as data;
import '../../data/repositories/customer_repository.dart' as data;
import '../../data/repositories/dashboard_repository.dart' as data;
import '../../data/repositories/item_repository.dart' as data;
import '../../data/repositories/notification_repository.dart' as data;
import '../../data/repositories/utilization_repository.dart' as data;
import '../../domain/repositories/accessory_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/challan_repository.dart';
import '../../domain/repositories/costing_repository.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/repositories/item_repository.dart';
import '../../domain/repositories/notification_repository.dart';

final erpApiDataSourceProvider = Provider<ErpApiDataSource>(
  (ref) => ErpApiDataSource(),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => data.AuthRepositoryImpl(ref.watch(erpApiDataSourceProvider)),
);

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => data.DashboardRepositoryImpl(ref.watch(erpApiDataSourceProvider)),
);

final customerRepositoryProvider = Provider<CustomerRepository>(
  (ref) => data.CustomerRepositoryImpl(ref.watch(erpApiDataSourceProvider)),
);

final itemRepositoryProvider = Provider<ItemRepository>(
  (ref) => data.ItemRepositoryImpl(ref.watch(erpApiDataSourceProvider)),
);

final costingRepositoryProvider = Provider<CostingRepository>(
  (ref) => data.CostingRepositoryImpl(ref.watch(erpApiDataSourceProvider)),
);

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => data.NotificationRepositoryImpl(ref.watch(erpApiDataSourceProvider)),
);

final accessoryRepositoryProvider = Provider<AccessoryRepository>(
  (ref) => data.AccessoryRepositoryImpl(AccessoryDataSource()),
);

final challanRepositoryProvider = Provider<ChallanRepository>(
  (ref) => data.ChallanRepositoryImpl(),
);


final utilizationRepositoryProvider = Provider<UtilizationRepository>(
      (ref) => data.UtilizationRepositoryImpl(ref.watch(erpApiDataSourceProvider)),
);