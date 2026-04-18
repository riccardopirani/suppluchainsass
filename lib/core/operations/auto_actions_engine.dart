import 'package:equatable/equatable.dart';

enum AutoActionSeverity { info, warning, critical }

class AutoActionSuggestion extends Equatable {
  const AutoActionSuggestion({
    required this.title,
    required this.body,
    required this.severity,
    required this.ruleId,
  });

  final String title;
  final String body;
  final AutoActionSeverity severity;
  final String ruleId;

  @override
  List<Object?> get props => [title, body, severity, ruleId];
}

/// Rule engine with clear predicates — extend with real thresholds from DB.
class AutoActionsEngine {
  const AutoActionsEngine();

  List<AutoActionSuggestion> evaluate({
    required List<Map<String, dynamic>> inventoryRows,
    required List<Map<String, dynamic>> machines,
    required List<Map<String, dynamic>> suppliers,
    required int openAlerts,
    required int delayedSuppliers,
  }) {
    final out = <AutoActionSuggestion>[];

    for (final row in inventoryRows) {
      final qty = _num(row['quantity']);
      final reorder = _num(row['reorder_point']);
      if (reorder > 0 && qty < reorder) {
        out.add(AutoActionSuggestion(
          title: 'Reorder suggested',
          body:
              '${row['item_name'] ?? 'SKU'} is below reorder point ($qty < $reorder).',
          severity: qty < reorder * 0.5 ? AutoActionSeverity.critical : AutoActionSeverity.warning,
          ruleId: 'stock_below_threshold',
        ));
      }
    }

    for (final m in machines) {
      final risk = _num(m['risk_score'] ?? m['failure_risk']);
      if (risk >= 80) {
        out.add(AutoActionSuggestion(
          title: 'Maintenance ticket',
          body: '${m['name'] ?? 'Machine'} risk at ${risk.round()}% — schedule inspection.',
          severity: AutoActionSeverity.critical,
          ruleId: 'machine_risk_high',
        ));
      }
    }

    for (final s in suppliers) {
      final score = _num(s['reliability_score'] ?? s['score']);
      if (score > 0 && score < 60) {
        out.add(AutoActionSuggestion(
          title: 'Flag vendor',
          body: '${s['name'] ?? 'Supplier'} score ${score.round()} — review terms & backup source.',
          severity: AutoActionSeverity.warning,
          ruleId: 'supplier_score_low',
        ));
      }
    }

    if (delayedSuppliers > 2) {
      out.add(AutoActionSuggestion(
        title: 'Delay cluster',
        body: '$delayedSuppliers suppliers behind — escalate daily stand-up.',
        severity: AutoActionSeverity.warning,
        ruleId: 'delays_threshold',
      ));
    }

    if (openAlerts > 6) {
      out.add(AutoActionSuggestion(
        title: 'Alert fatigue risk',
        body: '$openAlerts open alerts — prioritize top 3 by margin impact.',
        severity: AutoActionSeverity.info,
        ruleId: 'alerts_threshold',
      ));
    }

    out.sort((a, b) => b.severity.index.compareTo(a.severity.index));
    return out.take(12).toList();
  }

  static double _num(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}
