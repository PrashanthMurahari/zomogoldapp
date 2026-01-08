import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_quill/quill_delta.dart';

import '../dao/product_dao.dart';
import '../models/price_calculator.dart';
import '../models/product_model.dart';

const Color primaryPurple = Color(0xFF7F55B5);

class ProductDetailsViewPage extends StatefulWidget {
  final String productId;

  const ProductDetailsViewPage({super.key, required this.productId});

  @override
  State<ProductDetailsViewPage> createState() => _ProductDetailsViewPageState();
}

class _ProductDetailsViewPageState extends State<ProductDetailsViewPage> {
  final ProductDao _productDao = ProductDao();

  ProductModel? product;
  double goldRate = 0;
  double mrp = 0;
  double sellingPrice = 0;

  int _currentPage = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      final fetchedProduct = await _productDao.getProductById(widget.productId);
      final rate = await _productDao.getLatestRateByType(
        fetchedProduct.metalName,
      );

      final basePrice = PriceCalculator.calculateBasePrice(
        weight: fetchedProduct.weight,
        ratePerUnit: rate,
      );

      final makingChargeAmount = PriceCalculator.calculateMakingCharges(
        basePrice: basePrice,
        makingChargePercent: fetchedProduct.makingCharges,
      );

      final calculatedMrp = PriceCalculator.calculateMRP(
        basePrice: basePrice,
        makingChargeAmount: makingChargeAmount,
      );

      final calculatedSellingPrice = PriceCalculator.calculateSellingPrice(
        mrp: calculatedMrp,
        discountPercent: fetchedProduct.discount,
      );

      setState(() {
        product = fetchedProduct;
        goldRate = rate;
        mrp = calculatedMrp;
        sellingPrice = calculatedSellingPrice;
        loading = false;
      });
    } catch (e) {
      debugPrint("Error loading product: $e");
      setState(() => loading = false);
    }
  }

  QuillController _quillControllerFromJson(String json) {
    final delta = Delta.fromJson(jsonDecode(json));
    return QuillController(
      document: Document.fromDelta(delta),
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (product == null) {
      return const Scaffold(body: Center(child: Text("Product not found")));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: const [
          Icon(Icons.favorite_border),
          SizedBox(width: 16),
          Icon(Icons.share),
          SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 280,
              child: PageView.builder(
                itemCount: product!.images.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => Image.network(
                  product!.images[i],
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),

            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                product!.images.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? primaryPurple
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product!.metalName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        "₹ ${mrp.toStringAsFixed(0)}",
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "₹ ${sellingPrice.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),
                  const Text(
                    "MRP incl. of all taxes",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                  const SizedBox(height: 12),

                  /// Info Chips
                  Row(
                    children: [
                      _infoChip("${product!.purity}% Purity"),
                      const SizedBox(width: 8),
                      _infoChip("Making ${product!.makingCharges}%"),
                      const SizedBox(width: 8),
                      if (product!.hallmark) _infoChip("Hallmarked"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _expandableSection("Product details", product!.productInformation),
            _expandableSection("Specifications", product!.specifications),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _expandableSection(String title, String quillJson) {
    if (quillJson.isEmpty) return const SizedBox();

    final controller = _quillControllerFromJson(quillJson);

    return ExpansionTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        QuillEditor(
          controller: controller,
          scrollController: ScrollController(),
          focusNode: FocusNode(),
        ),
      ],
    );
  }
}
