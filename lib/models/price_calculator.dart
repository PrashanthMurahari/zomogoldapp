class PriceCalculator {
  static double calculateBasePrice({
    required double weight,
    required double ratePerUnit,
  }) {
    return weight * ratePerUnit;
  }

  static double calculateMakingCharges({
    required double basePrice,
    required double makingChargePercent,
  }) {
    return basePrice * (makingChargePercent / 100);
  }

  static double calculateMRP({
    required double basePrice,
    required double makingChargeAmount,
  }) {
    return basePrice + makingChargeAmount;
  }

  static double calculateSellingPrice({
    required double mrp,
    required double discountPercent,
  }) {
    return mrp - (mrp * (discountPercent / 100));
  }
}
