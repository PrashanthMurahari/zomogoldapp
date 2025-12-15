import 'package:cloud_firestore/cloud_firestore.dart';

class ProductRateModel {
  final String id;
  final String productType;
  final double price;
  final String unit;
  final String userId;
  final int timestamp;

  ProductRateModel({
    required this.id,
    required this.productType,
    required this.price,
    required this.unit,
    required this.userId,
    required this.timestamp,
  });

  factory ProductRateModel.fromSnapshot(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return ProductRateModel(
      id: snap.id,
      productType: snapshot["productType"] ?? 'Unknown',
      price: (snapshot["price"] as num).toDouble(),
      unit: snapshot["unit"] ?? 'N/A',
      userId: snapshot["userId"] ?? 'N/A',
      timestamp: (snapshot["timestamp"] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    "productType": productType,
    "price": price,
    "unit": unit,
    "userId": userId,
    "timestamp": timestamp,
  };
}
