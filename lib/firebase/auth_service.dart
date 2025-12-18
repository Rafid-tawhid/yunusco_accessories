// services/firebase_service.dart


import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/acessories_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveAccessory(GarmentAccessory accessory) async {
    DocumentReference docRef = FirebaseFirestore.instance.collection('accessories').doc();
    var data= accessory.copyWith(
      id: docRef.id
    );
    await docRef.set(data.toMap());
  }

  Future<void> updateAccessory(GarmentAccessory accessory) async {

    await _firestore.doc('accessories').update(accessory.toMap());
  }

  // In your firebase_service.dart
  Stream<List<GarmentAccessory>> getAccessoriesStream() {
    return FirebaseFirestore.instance
        .collection('accessories')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return GarmentAccessory.fromJson(doc.data());
      }).toList();
    });
  }
}
