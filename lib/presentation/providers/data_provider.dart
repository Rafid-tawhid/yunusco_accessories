import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/costing_items.dart';
import 'repository_providers.dart';

final rboProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(costingRepositoryProvider).getRbos();
});

final itemsProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((
  ref,
  rboId,
) async {
  return ref.watch(costingRepositoryProvider).getItemsForRbo(rboId);
});

final costingItemsProvider = FutureProvider.family<List<CostingItems>, String>((
  ref,
  itemRef,
) async {
  return ref.watch(costingRepositoryProvider).getCostingItems(itemRef);
});
