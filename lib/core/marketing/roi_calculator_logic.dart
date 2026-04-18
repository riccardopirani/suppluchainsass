/// Deterministic ROI estimate for marketing calculator (not financial advice).
class RoiCalculatorResult {
  const RoiCalculatorResult({
    required this.downtimeCost,
    required this.delayCost,
    required this.inventoryCarryingCost,
    required this.fabricOsLiftPercent,
    required this.estimatedMonthlySavings,
  });

  final double downtimeCost;
  final double delayCost;
  final double inventoryCarryingCost;
  final double fabricOsLiftPercent;
  final double estimatedMonthlySavings;
}

class RoiCalculatorLogic {
  RoiCalculatorLogic._();

  /// [monthlyRevenue] used as baseline scale only.
  /// [downtimeHours] × implicit €/h from revenue scale.
  /// [avgDelayCostPerEvent] monthly aggregate user estimate.
  /// [inventoryValue] carrying cost slice.
  static RoiCalculatorResult estimate({
    required double monthlyRevenue,
    required double downtimeHours,
    required double avgDelayCostPerEvent,
    required double inventoryValue,
  }) {
    final revenue = monthlyRevenue.clamp(0, 1e12);
    final impliedHourly = revenue > 0 ? (revenue / 720 / 50).clamp(50.0, 5000.0) : 120.0;
    final downtimeCost = downtimeHours.clamp(0, 744) * impliedHourly;
    final delayCost = avgDelayCostPerEvent.clamp(0, revenue);
    final inventoryCarryingCost = (inventoryValue * 0.18 / 12).clamp(0, revenue);

    const lift = 0.22;
    final raw = (downtimeCost + delayCost + inventoryCarryingCost) * lift;
    final cap = revenue * 0.08;
    final estimated = raw.clamp(0, cap > 0 ? cap : raw);

    return RoiCalculatorResult(
      downtimeCost: downtimeCost.toDouble(),
      delayCost: delayCost.toDouble(),
      inventoryCarryingCost: inventoryCarryingCost.toDouble(),
      fabricOsLiftPercent: lift * 100,
      estimatedMonthlySavings: estimated.toDouble(),
    );
  }
}
