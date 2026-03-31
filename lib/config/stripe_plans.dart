/// Per-seat pricing tiers (EUR cents per user per month).
/// The Edge Function receives `quantity` and `unitAmountCents` and creates
/// an inline `price_data` in Stripe — no pre-existing Price objects required.
class SeatPricing {
  const SeatPricing._();

  static const String currency = 'eur';
  static const String productName = 'FabricOS Platform';

  /// Tier thresholds: [maxSeats, centPerUser].
  /// Last tier covers everything above.
  static const List<(int, int)> tiers = [
    (10, 900),   // 1-10 users  → €9 /user/month
    (50, 800),   // 11-50 users → €8 /user/month
    (9999, 700), // 51+ users   → €7 /user/month
  ];

  static int unitCentsForQuantity(int qty) {
    for (final (max, cents) in tiers) {
      if (qty <= max) return cents;
    }
    return tiers.last.$2;
  }

  static double monthlyTotal(int qty) =>
      qty * unitCentsForQuantity(qty) / 100.0;

  static double unitPrice(int qty) => unitCentsForQuantity(qty) / 100.0;
}
