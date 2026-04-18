/// Client-side scenario model for executive what-if (illustrative).
abstract final class WhatIfEstimator {
  static Map<String, dynamic> combined({
    required double supplierDelayDays,
    required double demandSpikePercent,
    required double machineOutageHours,
    double materialPriceIncreasePercent = 0,
  }) {
    final mat = materialPriceIncreasePercent.clamp(0, 100);
    final rev = -supplierDelayDays * 12000 -
        machineOutageHours * 850 +
        demandSpikePercent * 4200 -
        mat * 9500;
    final stockout = (28 + supplierDelayDays * 5 + demandSpikePercent * 0.4 + machineOutageHours * 0.06)
        .clamp(5.0, 96.0);
    final prodDelay = supplierDelayDays * 0.85 + machineOutageHours / 24 * 0.55;
    final margin =
        -supplierDelayDays * 6200 - machineOutageHours * 420 - mat * 14800 + demandSpikePercent * 2100;
    return {
      'revenue_impact_eur': rev,
      'stockout_risk_pct': stockout,
      'production_delay_days': prodDelay,
      'margin_impact_eur': margin,
    };
  }
}
