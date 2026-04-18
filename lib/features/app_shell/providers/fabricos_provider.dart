import 'dart:math';

import 'package:fabricos/config/plan_catalog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FabricUserContext {
  const FabricUserContext({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.role,
    required this.companyId,
    required this.companyName,
  });

  final String userId;
  final String email;
  final String fullName;
  final String role;
  final String? companyId;
  final String? companyName;

  bool get isOnboarded => companyId != null;
}

class DashboardSnapshot {
  const DashboardSnapshot({
    required this.activeOrders,
    required this.runningMachines,
    required this.warningMachines,
    required this.stoppedMachines,
    required this.delayedSuppliers,
    required this.openAlerts,
  });

  final int activeOrders;
  final int runningMachines;
  final int warningMachines;
  final int stoppedMachines;
  final int delayedSuppliers;
  final int openAlerts;
}

final fabricSupabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final fabricosRepositoryProvider = Provider<FabricOSRepository>((ref) {
  final client = ref.watch(fabricSupabaseClientProvider);
  return FabricOSRepository(client);
});

final fabricUserContextProvider = FutureProvider<FabricUserContext>((
  ref,
) async {
  final client = ref.watch(fabricSupabaseClientProvider);
  final currentUser = client.auth.currentUser;

  if (currentUser == null) {
    throw Exception('User not authenticated');
  }

  Map<String, dynamic>? profile = await client
      .from('users')
      .select('id, email, full_name, role, company_id, companies(name)')
      .eq('id', currentUser.id)
      .maybeSingle();

  if (profile == null) {
    await client.from('users').insert({
      'id': currentUser.id,
      'email': currentUser.email,
      'full_name': currentUser.userMetadata?['full_name']?.toString() ?? '',
      'role': 'admin',
    });

    profile = await client
        .from('users')
        .select('id, email, full_name, role, company_id, companies(name)')
        .eq('id', currentUser.id)
        .single();
  }

  final company = profile['companies'] as Map<String, dynamic>?;

  return FabricUserContext(
    userId: currentUser.id,
    email: (profile['email'] ?? currentUser.email ?? '').toString(),
    fullName: (profile['full_name'] ?? '').toString(),
    role: (profile['role'] ?? 'operator').toString(),
    companyId: profile['company_id']?.toString(),
    companyName: company?['name']?.toString(),
  );
});

final currentCompanyIdProvider = FutureProvider<String>((ref) async {
  final context = await ref.watch(fabricUserContextProvider.future);
  final companyId = context.companyId;

  if (companyId == null) {
    throw StateError('Company not configured yet. Complete onboarding first.');
  }

  return companyId;
});

final machinesProvider = StreamProvider<List<Map<String, dynamic>>>((
  ref,
) async* {
  final client = ref.watch(fabricSupabaseClientProvider);
  final companyId = await ref.watch(currentCompanyIdProvider.future);

  yield* client
      .from('machines')
      .stream(primaryKey: ['id'])
      .eq('company_id', companyId)
      .order('updated_at', ascending: false);
});

final alertsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) async* {
  final client = ref.watch(fabricSupabaseClientProvider);
  final companyId = await ref.watch(currentCompanyIdProvider.future);

  yield* client
      .from('alerts')
      .stream(primaryKey: ['id'])
      .eq('company_id', companyId)
      .order('created_at', ascending: false);
});

final ordersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = ref.watch(fabricSupabaseClientProvider);
  final companyId = await ref.watch(currentCompanyIdProvider.future);

  return client
      .from('orders')
      .select('*, suppliers(name)')
      .eq('company_id', companyId)
      .order('created_at', ascending: false);
});

final suppliersProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final client = ref.watch(fabricSupabaseClientProvider);
  final companyId = await ref.watch(currentCompanyIdProvider.future);

  return client
      .from('suppliers')
      .select()
      .eq('company_id', companyId)
      .order('name', ascending: true);
});

final maintenanceLogsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final client = ref.watch(fabricSupabaseClientProvider);
  final companyId = await ref.watch(currentCompanyIdProvider.future);

  return client
      .from('maintenance_logs')
      .select('*, machines(name, type)')
      .eq('company_id', companyId)
      .order('performed_at', ascending: false)
      .limit(50);
});

final esgReportsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final client = ref.watch(fabricSupabaseClientProvider);
  final companyId = await ref.watch(currentCompanyIdProvider.future);

  return client
      .from('esg_reports')
      .select()
      .eq('company_id', companyId)
      .order('report_month', ascending: false);
});

final dashboardSnapshotProvider = FutureProvider<DashboardSnapshot>((
  ref,
) async {
  final client = ref.watch(fabricSupabaseClientProvider);
  final companyId = await ref.watch(currentCompanyIdProvider.future);

  final activeOrdersFuture = client
      .from('orders')
      .select('id')
      .eq('company_id', companyId)
      .neq('status', 'completed');

  final machinesFuture = client
      .from('machines')
      .select('status')
      .eq('company_id', companyId);

  final delayedSuppliersFuture = client
      .from('orders')
      .select('supplier_id')
      .eq('company_id', companyId)
      .gt('delay_days', 0);

  final alertsFuture = client
      .from('alerts')
      .select('id')
      .eq('company_id', companyId)
      .eq('resolved', false);

  final results = await Future.wait([
    activeOrdersFuture,
    machinesFuture,
    delayedSuppliersFuture,
    alertsFuture,
  ]);

  final activeOrders = (results[0] as List).length;
  final machines = (results[1] as List).cast<Map<String, dynamic>>();
  final delayedSuppliers = (results[2] as List)
      .map((e) => (e as Map<String, dynamic>)['supplier_id'])
      .where((id) => id != null)
      .toSet()
      .length;
  final openAlerts = (results[3] as List).length;

  final runningMachines = machines
      .where((m) => m['status'] == 'running')
      .length;
  final warningMachines = machines
      .where((m) => m['status'] == 'warning')
      .length;
  final stoppedMachines = machines
      .where((m) => m['status'] == 'stopped')
      .length;

  return DashboardSnapshot(
    activeOrders: activeOrders,
    runningMachines: runningMachines,
    warningMachines: warningMachines,
    stoppedMachines: stoppedMachines,
    delayedSuppliers: delayedSuppliers,
    openAlerts: openAlerts,
  );
});

class BillingStatus {
  const BillingStatus({
    required this.hasActiveSubscription,
    required this.inTrial,
    this.trialEndsAt,
    this.subscription,
    this.planKey = 'starter',
  });

  final bool hasActiveSubscription;
  final bool inTrial;
  final DateTime? trialEndsAt;
  final Map<String, dynamic>? subscription;

  /// Raw plan string from Stripe/subscription metadata when present.
  final String planKey;

  bool get canAccessApp => hasActiveSubscription || inTrial;

  SubscriptionPlanTier get resolvedTier {
    if (inTrial && !hasActiveSubscription) {
      return SubscriptionPlanTier.growth;
    }
    final parsed = PlanCatalog.tryParseTier(planKey);
    if (parsed != null) return parsed;
    return SubscriptionPlanTier.starter;
  }

  /// True when subscription was activated via App Store / Play Billing (`register-mobile-purchase`).
  bool get isStoreBillingSubscription {
    final meta = subscription?['metadata'];
    if (meta is! Map) return false;
    final src = meta['source']?.toString() ?? '';
    return src.startsWith('iap_');
  }
}

final billingStatusProvider = FutureProvider<BillingStatus>((ref) async {
  final client = ref.watch(fabricSupabaseClientProvider);
  final companyId = await ref.watch(currentCompanyIdProvider.future);

  final company = await client
      .from('companies')
      .select('trial_ends_at')
      .eq('id', companyId)
      .maybeSingle();

  final sub = await client
      .from('subscriptions')
      .select()
      .eq('company_id', companyId)
      .order('updated_at', ascending: false)
      .limit(1)
      .maybeSingle();

  final trialEndsAt = DateTime.tryParse(company?['trial_ends_at']?.toString() ?? '');
  final inTrial = trialEndsAt != null && trialEndsAt.isAfter(DateTime.now());
  final status = (sub?['status'] ?? '').toString();
  final active = status == 'active' || status == 'trialing' || status == 'past_due';

  var planKey = 'starter';
  if (sub != null) {
    final meta = sub['metadata'];
    if (meta is Map && meta['plan'] != null) {
      planKey = meta['plan'].toString();
    } else if (sub['plan'] != null) {
      planKey = sub['plan'].toString();
    }
  }

  return BillingStatus(
    hasActiveSubscription: active,
    inTrial: inTrial,
    trialEndsAt: trialEndsAt,
    subscription: sub,
    planKey: planKey,
  );
});

final subscriptionEntitlementsProvider = Provider<SubscriptionEntitlements>((ref) {
  final billing = ref.watch(billingStatusProvider).valueOrNull;
  final tier = billing?.resolvedTier ?? SubscriptionPlanTier.starter;
  return SubscriptionEntitlements(tier: tier);
});

final paymentHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = ref.watch(fabricSupabaseClientProvider);
  final companyId = await ref.watch(currentCompanyIdProvider.future);
  return client
      .from('payment_history')
      .select()
      .eq('company_id', companyId)
      .order('paid_at', ascending: false)
      .limit(50);
});

class FabricOSRepository {
  FabricOSRepository(this._client);

  final SupabaseClient _client;

  Future<void> createCompanyAndAssignUser({
    required String companyName,
    required String sizeBand,
    String? plan,
    bool startTrial = true,
  }) async {
    final response = await _client.functions.invoke(
      'bootstrap-company',
      body: {
        'name': companyName,
        'sizeBand': sizeBand,
        'plan': plan,
        'trialDays': startTrial ? 30 : 0,
      },
    );
    if (response.status >= 400) {
      throw Exception(
        'Bootstrap company failed (${response.status}): ${response.data}',
      );
    }
  }

  Future<void> createMachine({
    required String companyId,
    required String name,
    required String type,
    String? country,
    String? city,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    final inferred = _inferCoordinates(country: country, city: city);
    final resolvedLatitude = latitude ?? inferred?['latitude'];
    final resolvedLongitude = longitude ?? inferred?['longitude'];

    await _client.from('machines').insert({
      'company_id': companyId,
      'name': name,
      'type': type,
      'status': 'running',
      'last_maintenance_at': DateTime.now()
          .subtract(const Duration(days: 30))
          .toIso8601String(),
      'failure_risk': 0.18,
      'country': country,
      'city': city,
      'address': address,
      'latitude': resolvedLatitude,
      'longitude': resolvedLongitude,
    });
  }

  Future<void> addMaintenanceLog({
    required String companyId,
    required String machineId,
    required String notes,
    required String technician,
    required double cost,
  }) async {
    await _client.from('maintenance_logs').insert({
      'company_id': companyId,
      'machine_id': machineId,
      'notes': notes,
      'technician': technician,
      'cost': cost,
      'performed_at': DateTime.now().toIso8601String(),
    });

    await _client
        .from('machines')
        .update({
          'last_maintenance_at': DateTime.now().toIso8601String(),
          'status': 'running',
          'failure_risk': 0.1,
        })
        .eq('id', machineId);
  }

  Future<double> simulateTelemetryAndPredictRisk({
    required String companyId,
    required String machineId,
  }) async {
    final rng = Random();
    final temperature = 62 + (rng.nextDouble() * 42);
    final vibration = 0.8 + (rng.nextDouble() * 5.2);
    final pressure = 78 + (rng.nextDouble() * 42);

    await _client.from('machine_telemetry').insert({
      'company_id': companyId,
      'machine_id': machineId,
      'temperature': temperature,
      'vibration': vibration,
      'pressure': pressure,
      'recorded_at': DateTime.now().toIso8601String(),
    });

    double risk = _localRiskScore(
      temperature: temperature,
      vibration: vibration,
      pressure: pressure,
    );
    try {
      final response = await _client.functions.invoke(
        'predict-maintenance-risk',
        body: {
          'machineId': machineId,
          'companyId': companyId,
          'temperature': temperature,
          'vibration': vibration,
          'pressure': pressure,
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['risk'] != null) {
        risk = (data['risk'] as num).toDouble();
      }
    } catch (_) {
      // Keep local placeholder logic when function is unavailable.
    }

    final status = risk >= 0.85
        ? 'stopped'
        : risk >= 0.65
        ? 'warning'
        : 'running';

    await _client
        .from('machines')
        .update({
          'status': status,
          'failure_risk': risk,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', machineId);

    if (risk >= 0.7) {
      await _client.from('alerts').insert({
        'company_id': companyId,
        'machine_id': machineId,
        'type': 'predictive_maintenance',
        'severity': risk > 0.85 ? 'critical' : 'warning',
        'title': 'Failure risk detected',
        'message':
            'Machine shows anomalous telemetry. Risk score: ${(risk * 100).toStringAsFixed(1)}%.',
        'ai_generated': true,
      });
    }

    return risk;
  }

  double _localRiskScore({
    required double temperature,
    required double vibration,
    required double pressure,
  }) {
    final tempFactor = ((temperature - 60) / 45).clamp(0, 1);
    final vibrationFactor = ((vibration - 1.5) / 4).clamp(0, 1);
    final pressureFactor = ((pressure - 80) / 40).clamp(0, 1);

    return ((tempFactor * 0.35) +
            (vibrationFactor * 0.45) +
            (pressureFactor * 0.2))
        .clamp(0.05, 0.99);
  }

  Map<String, double>? _inferCoordinates({String? country, String? city}) {
    final key =
        '${(country ?? '').trim().toLowerCase()}|${(city ?? '').trim().toLowerCase()}';

    const known = <String, Map<String, double>>{
      'italy|milan': {'latitude': 45.4642, 'longitude': 9.19},
      'italy|turin': {'latitude': 45.0703, 'longitude': 7.6869},
      'italy|bologna': {'latitude': 44.4949, 'longitude': 11.3426},
      'germany|munich': {'latitude': 48.1351, 'longitude': 11.582},
      'france|lyon': {'latitude': 45.764, 'longitude': 4.8357},
      'spain|barcelona': {'latitude': 41.3874, 'longitude': 2.1686},
      'united states|detroit': {'latitude': 42.3314, 'longitude': -83.0458},
      'united states|chicago': {'latitude': 41.8781, 'longitude': -87.6298},
      'japan|osaka': {'latitude': 34.6937, 'longitude': 135.5023},
      'china|shenzhen': {'latitude': 22.5431, 'longitude': 114.0579},
      'brazil|sao paulo': {'latitude': -23.5558, 'longitude': -46.6396},
      'india|pune': {'latitude': 18.5204, 'longitude': 73.8567},
    };

    return known[key];
  }

  Future<void> createOrder({
    required String companyId,
    required String supplierId,
    required String orderNumber,
    required String status,
    required DateTime expectedDelivery,
    required double amount,
  }) async {
    await _client.from('orders').insert({
      'company_id': companyId,
      'supplier_id': supplierId,
      'order_number': orderNumber,
      'status': status,
      'expected_delivery_date': expectedDelivery.toIso8601String(),
      'amount': amount,
      'delay_days': 0,
    });
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    final now = DateTime.now();
    await _client
        .from('orders')
        .update({
          'status': status,
          'delivered_at': status == 'completed' ? now.toIso8601String() : null,
          'updated_at': now.toIso8601String(),
        })
        .eq('id', orderId);
  }

  Future<void> deleteMachine({
    required String companyId,
    required String machineId,
  }) async {
    await _client
        .from('machines')
        .delete()
        .eq('id', machineId)
        .eq('company_id', companyId);
  }

  Future<void> deleteOrder({
    required String companyId,
    required String orderId,
  }) async {
    await _client
        .from('orders')
        .delete()
        .eq('id', orderId)
        .eq('company_id', companyId);
  }

  Future<void> deleteSupplier({
    required String companyId,
    required String supplierId,
  }) async {
    await _client
        .from('suppliers')
        .delete()
        .eq('id', supplierId)
        .eq('company_id', companyId);
  }

  Future<void> deleteEsgReport({
    required String companyId,
    required String reportId,
  }) async {
    await _client
        .from('esg_reports')
        .delete()
        .eq('id', reportId)
        .eq('company_id', companyId);
  }

  Future<int> analyzeOrderRisks({required String companyId}) async {
    try {
      final response = await _client.functions.invoke(
        'analyze-order-risks',
        body: {'companyId': companyId},
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['created'] != null) {
        return (data['created'] as num).toInt();
      }
    } catch (_) {
      // Fallback below.
    }

    final now = DateTime.now();
    final orders = await _client
        .from('orders')
        .select('id, supplier_id, order_number, expected_delivery_date, status')
        .eq('company_id', companyId)
        .neq('status', 'completed');

    var created = 0;
    for (final row in orders) {
      final expected = DateTime.tryParse(
        row['expected_delivery_date']?.toString() ?? '',
      );
      if (expected == null) continue;
      final delay = now.difference(expected).inDays;
      if (delay <= 0) continue;

      await _client
          .from('orders')
          .update({'delay_days': delay})
          .eq('id', row['id']);
      await _client.from('alerts').insert({
        'company_id': companyId,
        'order_id': row['id'],
        'supplier_id': row['supplier_id'],
        'type': 'order_delay_risk',
        'severity': delay >= 7 ? 'critical' : 'warning',
        'title': 'Order risk delay',
        'message': 'Order ${row['order_number']} is delayed by $delay day(s).',
        'ai_generated': true,
      });
      created += 1;
    }

    return created;
  }

  Future<void> createSupplier({
    required String companyId,
    required String name,
    required double reliabilityScore,
    required String complianceStatus,
    required String riskLevel,
    String? contactEmail,
  }) async {
    await _client.from('suppliers').insert({
      'company_id': companyId,
      'name': name,
      'reliability_score': reliabilityScore,
      'compliance_status': complianceStatus,
      'risk_level': riskLevel,
      'contact_email': contactEmail,
      'avg_delay_days': 0,
    });
  }

  Future<Map<String, dynamic>> generateEsgReport({
    required String companyId,
    required DateTime month,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'generate-esg-report',
        body: {
          'companyId': companyId,
          'reportMonth': DateTime(month.year, month.month, 1).toIso8601String(),
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
    } catch (_) {
      // fallback below
    }

    final rng = Random();
    final emissions = (38 + rng.nextDouble() * 24);
    final supplierCompliance = (74 + rng.nextDouble() * 21);

    final row = await _client
        .from('esg_reports')
        .insert({
          'company_id': companyId,
          'report_month': DateTime(
            month.year,
            month.month,
            1,
          ).toIso8601String(),
          'emissions_tco2': emissions,
          'supplier_compliance_score': supplierCompliance,
          'summary':
              'Monthly ESG report generated with mock operational and supplier compliance data.',
          'metadata': {
            'energy_efficiency_index': (70 + rng.nextDouble() * 20),
            'waste_recovery_rate': (55 + rng.nextDouble() * 30),
          },
        })
        .select()
        .single();

    return row;
  }

  Future<String?> createCheckoutSession({
    required String companyId,
    required int quantity,
    required int unitAmountCents,
    String currency = 'eur',
    int trialDays = 0,
    String? successUrl,
    String? cancelUrl,
  }) async {
    final body = <String, dynamic>{
      'companyId': companyId,
      'quantity': quantity,
      'unitAmountCents': unitAmountCents,
      'currency': currency,
      'trialDays': trialDays,
    };
    if (successUrl != null) body['successUrl'] = successUrl;
    if (cancelUrl != null) body['cancelUrl'] = cancelUrl;

    final response = await _client.functions.invoke(
      'create-stripe-checkout-session',
      body: body,
    );
    final data = response.data;
    if (data is Map<String, dynamic>) return data['url']?.toString();
    return null;
  }

  /// After a successful App Store / Play Billing transaction, registers entitlement server-side.
  Future<void> registerMobilePurchase({
    required String companyId,
    required String plan,
    required String platform,
    required String productId,
    required String purchaseId,
    String? verificationData,
  }) async {
    final response = await _client.functions.invoke(
      'register-mobile-purchase',
      body: {
        'companyId': companyId,
        'plan': plan,
        'platform': platform,
        'productId': productId,
        'purchaseId': purchaseId,
        'verificationData': verificationData ?? '',
      },
    );
    if (response.status >= 400) {
      throw Exception(
        'register-mobile-purchase failed (${response.status}): ${response.data}',
      );
    }
  }

  Future<String?> createPortalSession({
    required String companyId,
    String? returnUrl,
  }) async {
    final body = <String, dynamic>{'companyId': companyId};
    if (returnUrl != null) body['returnUrl'] = returnUrl;

    final response = await _client.functions.invoke(
      'create-stripe-portal-session',
      body: body,
    );
    final data = response.data;
    if (data is Map<String, dynamic>) return data['url']?.toString();
    return null;
  }
}
