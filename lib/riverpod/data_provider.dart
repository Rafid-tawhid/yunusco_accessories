import 'package:flutter/cupertino.dart';

import '../helper_class/api_service_class.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/costing_items.dart';

final rboProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final api = ApiService();
  final response = await api.get('ItemPrice/RboHasItemVariablePrice');

  debugPrint('This is response ${response}');
  if (response != null && response.statusCode == 200) {
    final data = response.data;
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    } else {
      return [];
    }
  } else {
    return [];
  }
});


final itemsProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, rboId) async {
  final api = ApiService();
  final response = await api.get('ItemPrice/ItemsDdl', query: {'rboId': rboId});

  if (response == null || response.data == null) return [];

  if (response.data is List) {
    return List<Map<String, dynamic>>.from(response.data);
  } else {
    return [];
  }
});


final costingItemsProvider = FutureProvider.family<List<CostingItems>, String>((ref, itemRef) async {
  final api = ApiService();
  final response = await api.get('ItemPrice/Prices', query: {'ItemRef': itemRef});

  if (response != null && response.statusCode == 200) {
    final List data = response.data;
    return data.map((e) => CostingItems.fromJson(e)).toList();
  } else {
    throw Exception('Failed to load costing items');
  }
});
