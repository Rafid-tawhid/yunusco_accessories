// providers/accessory_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../firebase/auth_service.dart';
import '../models/acessories_model.dart';

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

final accessorySaveProvider = FutureProvider.family<void, GarmentAccessory>((ref, accessory) async {
  final service = ref.read(firebaseServiceProvider);
  await service.saveAccessory(accessory);
});


final accessoriesListProvider = StreamProvider<List<GarmentAccessory>>((ref) {
  final service = ref.read(firebaseServiceProvider);
  return service.getAccessoriesStream();
});