// providers/accessory_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yunusco_accessories/helper_class/api_service_class.dart';
import '../firebase/auth_service.dart';
import '../models/acessories_model.dart';
import '../models/items_model.dart';

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});
final apiService = Provider<ApiService>((ref) => ApiService());

final accessorySaveProvider = FutureProvider.family<void, GarmentAccessory>((
  ref,
  accessory,
) async {
  final service = ref.read(firebaseServiceProvider);
  await service.saveAccessory(accessory);
});

final accessoriesListProvider = StreamProvider<List<GarmentAccessory>>((ref) {
  final service = ref.read(firebaseServiceProvider);
  return service.getAccessoriesStream();
});



final accessoriesItemListProvider = FutureProvider<List<ItemsModel>>((
  ref,
) async {
  final service = ref.read(apiService);
  List<ItemsModel> itemList = [];
  var data = await service.get('Priceing/GetNewItem?searchText=');
  if (data!.statusCode == 200) {
    for (var i in data.data) {
      itemList.add(ItemsModel.fromJson(i));
    }
  }
  return itemList;
});
