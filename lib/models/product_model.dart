import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String productId;
  final String categoryId;
  final String userId;
  final List<String> images;
  final String metalName;
  final double weight;
  final double cost;
  final String weightUnit;
  final String costUnit;
  final double purity;
  final double makingCharges;
  final double discount;
  final String tagId;
  final String productInformation;
  final String specifications;
  final bool hallmark;
  final bool customizable;
  final DateTime createdTimestamp;
  final DateTime modifiedTimestamp;

  ProductModel({
    required this.productId,
    required this.categoryId,
    required this.userId,
    required this.images,
    required this.metalName,
    required this.weight,
    required this.cost,
    required this.weightUnit,
    required this.costUnit,
    required this.purity,
    required this.makingCharges,
    required this.discount,
    required this.tagId,
    required this.productInformation,
    required this.specifications,
    required this.hallmark,
    required this.customizable,
    required this.createdTimestamp,
    required this.modifiedTimestamp,
  });

  factory ProductModel.fromSnapshot(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;

    return ProductModel(
      productId: data["productId"],
      categoryId: data["categoryId"],
      userId: data["userId"],
      images: List<String>.from(data["images"] ?? []),
      metalName: data["metalName"],
      weight: (data["weight"] ?? 0).toDouble(),
      cost: (data["cost"] ?? 0).toDouble(),
      weightUnit: data["weightUnit"],
      costUnit: data["costUnit"],
      purity: (data["purity"] ?? 0).toDouble(),
      makingCharges: (data["makingCharges"] ?? 0).toDouble(),
      discount: (data["discount"] ?? 0).toDouble(),
      tagId: data["tagId"],
      productInformation: data["productInformation"],
      specifications: data["specifications"] ?? "",
      hallmark: data["hallmark"] ?? false,
      customizable: data["customizable"] ?? false,
      createdTimestamp:
      (data["createdTimestamp"] as Timestamp).toDate(),
      modifiedTimestamp:
      (data["modifiedTimestamp"] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "productId": productId,
      "categoryId": categoryId,
      "userId": userId,
      "images": images,
      "metalName": metalName,
      "weight": weight,
      "cost": cost,
      "weightUnit": weightUnit,
      "costUnit": costUnit,
      "purity": purity,
      "makingCharges": makingCharges,
      "discount": discount,
      "tagId": tagId,
      "productInformation": productInformation,
      "specifications": specifications,
      "hallmark": hallmark,
      "customizable": customizable,
      "createdTimestamp": Timestamp.fromDate(createdTimestamp),
      "modifiedTimestamp": Timestamp.fromDate(modifiedTimestamp),
    };
  }
}
