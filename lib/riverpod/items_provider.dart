import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../helper_class/api_service_class.dart';
import '../models/items_model.dart';

// ============================================
// PROVIDER 1: API Service Provider
// ============================================
// This makes ApiService available throughout the app
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// ============================================
// PROVIDER 2: Items List Provider
// ============================================
// This fetches items from API and handles loading/error states
final itemsListProvider = FutureProvider<List<ItemsModel>>((ref) async {
  final apiService = ref.read(apiServiceProvider);

  List<ItemsModel> items=[];
  // Make API call
  final response = await apiService.get('Priceing/GetNewItem', query: {
    'searchText': '',
  });
  debugPrint('Response: $response');
  if(response!=null){
    // Convert each JSON to ItemsModel
     for(var i in response.data){
       items.add(ItemsModel.fromJson(i));
     }

     debugPrint('Items: $items');
  }

  return items;
});

// ============================================
// PROVIDER 3: Filtered Items Provider
// ============================================
// This creates a filtered version of the items list
final filteredItemsProvider = Provider<List<ItemsModel>>((ref) {
  final itemsAsync = ref.watch(itemsListProvider);
  final searchTerm = ref.watch(searchTermProvider);

  // If still loading or error, return empty list
  return itemsAsync.when(
    data: (items) {
      if (searchTerm.isEmpty) return items;

      // Filter items by name, product name, or item ref
      return items.where((item) {
        final term = searchTerm.toLowerCase();
        return item.displayName.toLowerCase().contains(term) ||
            (item.itemRef?.toLowerCase().contains(term) ?? false) ||
            (item.itemName?.toLowerCase().contains(term) ?? false);
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// ============================================
// PROVIDER 4: Search Term Provider
// ============================================
// This holds the current search text
final searchTermProvider = StateProvider<String>((ref) => '');

// ============================================
// PROVIDER 5: Selected Category Provider
// ============================================
// For filtering by product line
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// ============================================
// PROVIDER 6: Categories List Provider
// ============================================

// ============================================
// PROVIDER 7: Category Filtered Items
// ============================================
final categoryFilteredItemsProvider = Provider<List<ItemsModel>>((ref) {
  final items = ref.watch(filteredItemsProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);

  if (selectedCategory == null || selectedCategory == 'All') {
    return items;
  }

  return items.where((item) =>
  item.productLineName == selectedCategory
  ).toList();
});

// ============================================
// PROVIDER 8: Item Detail Provider (for single item)
// ============================================
