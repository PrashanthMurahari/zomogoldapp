import 'package:flutter/material.dart';
import 'package:zomogoldapp/screens/product_view_page.dart';

import '../models/price_calculator.dart';
import '../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final double ratePerGram;

  const ProductCard({
    super.key,
    required this.product,
    required this.ratePerGram,
  });

  @override
  Widget build(BuildContext context) {
    final basePrice = PriceCalculator.calculateBasePrice(
      weight: product.weight,
      ratePerUnit: ratePerGram,
    );

    final makingCharge = PriceCalculator.calculateMakingCharges(
      basePrice: basePrice,
      makingChargePercent: product.makingCharges,
    );

    final mrp = PriceCalculator.calculateMRP(
      basePrice: basePrice,
      makingChargeAmount: makingCharge,
    );

    final sellingPrice = PriceCalculator.calculateSellingPrice(
      mrp: mrp,
      discountPercent: product.discount,
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ProductDetailsViewPage(productId: product.productId),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                    child: product.images.isNotEmpty
                        ? Image.network(
                            product.images.first,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => _imagePlaceholder(),
                          )
                        : _imagePlaceholder(),
                  ),
                  const Positioned(
                    top: 10,
                    right: 10,
                    child: Icon(Icons.favorite_border, color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹ ${sellingPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹ ${mrp.toStringAsFixed(0)}',
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.tagId,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported,
        size: 40,
        color: Colors.grey,
      ),
    );
  }
}
