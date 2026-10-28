// providers/accessory_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/acessories_model.dart';
import '../../models/items_model.dart';
import 'repository_providers.dart';

final accessorySaveProvider = FutureProvider.family<void, GarmentAccessory>((
  ref,
  accessory,
) async {
  await ref.read(accessoryRepositoryProvider).saveAccessory(accessory);
});

final accessoriesListProvider = StreamProvider<List<GarmentAccessory>>((ref) {
  return ref.watch(accessoryRepositoryProvider).watchAccessories();
});

final accessoriesItemListProvider = FutureProvider<List<ItemsModel>>((
  ref,
) async {
  return ref.watch(itemRepositoryProvider).getItems();
});
