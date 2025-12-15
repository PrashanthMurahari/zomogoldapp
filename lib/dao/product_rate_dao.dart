import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_rate_model.dart';

class ProductRateDao {
  final CollectionReference _rateRef = FirebaseFirestore.instance.collection(
    "product rate",
  );

  Future<void> addRateEntry(ProductRateModel rate) {
    return _rateRef.doc(rate.id).set(rate.toJson());
  }

  Stream<List<ProductRateModel>> getRateHistory() {
    return _rateRef
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductRateModel.fromSnapshot(doc))
              .toList(),
        );
  }
}
