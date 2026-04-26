import 'package:fabricos/config/plan_catalog.dart';
import 'package:fabricos/features/app_shell/app_shell.dart';
import 'package:fabricos/features/app_shell/providers/fabricos_provider.dart';
import 'package:fabricos/features/auth/presentation/forgot_password_page.dart';
import 'package:fabricos/features/auth/presentation/login_page.dart';
import 'package:fabricos/features/auth/presentation/register_page.dart';
import 'package:fabricos/features/auth/providers/auth_provider.dart';
import 'package:fabricos/features/billing/presentation/billing_page.dart';
import 'package:fabricos/features/dashboard/presentation/dashboard_page.dart';
import 'package:fabricos/features/machines/presentation/machines_page.dart';
import 'package:fabricos/features/onboarding/presentation/onboarding_page.dart';
import 'package:fabricos/features/offline_sync/presentation/offline_sync_page.dart';
import 'package:fabricos/features/orders/presentation/orders_page.dart';
import 'package:fabricos/features/plant_floor/presentation/plant_floor_page.dart';
import 'package:fabricos/features/reports/presentation/reports_page.dart';
import 'package:fabricos/features/settings/presentation/settings_page.dart';
import 'package:fabricos/features/team/presentation/team_page.dart';
import 'package:fabricos/features/supply_chain/presentation/inventory_page.dart';
import 'package:fabricos/features/supply_chain/presentation/shipments_page.dart';
import 'package:fabricos/features/supply_chain/presentation/simulation_page.dart';
import 'package:fabricos/features/supply_chain/presentation/supply_dashboard_page.dart';
import 'package:fabricos/features/suppliers/presentation/suppliers_page.dart';
import 'package:fabricos/features/vendor_portal/presentation/vendor_portal_page.dart';
import 'package:fabricos/features/suppliers/presentation/supplier_detail_page.dart';
import 'package:fabricos/features/control_tower/presentation/control_tower_page.dart';
import 'package:fabricos/features/executive/presentation/executive_report_page.dart';
import 'package:fabricos/features/forecasting/presentation/forecasting_page.dart';
import 'package:fabricos/features/website/presentation/book_demo_page.dart';
import 'package:fabricos/features/website/presentation/case_studies_page.dart';
import 'package:fabricos/features/website/presentation/contact_page.dart';
import 'package:fabricos/features/website/presentation/factory_audit_page.dart';
import 'package:fabricos/features/website/presentation/faq_page.dart';
import 'package:fabricos/features/website/presentation/features_page.dart';
import 'package:fabricos/features/website/presentation/home_page.dart';
import 'package:fabricos/features/website/presentation/legal_page.dart';
import 'package:fabricos/features/website/presentation/pricing_page.dart';
import 'package:fabricos/features/website/presentation/roi_calculator_page.dart';
import 'package:fabricos/features/website/presentation/website_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final billingAsync = ref.watch(billingStatusProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      if (authState.isLoading) {
        return '/loading';
      }

      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute =
          state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register') ||
          state.matchedLocation.startsWith('/forgot-password');
      final isAppRoute = state.matchedLocation.startsWith('/app');
      final loc = state.matchedLocation;

      if (isAppRoute && !isLoggedIn) {
        return '/login';
      }

      if (isAuthRoute && isLoggedIn) {
        return '/app';
      }

      if (isLoggedIn &&
          isAppRoute &&
          !loc.startsWith('/app/billing') &&
          billingAsync.hasValue) {
        final b = billingAsync.requireValue;
        if (b.canAccessApp) {
          final def = PlanCatalog.byTier(b.resolvedTier);
          if (loc.contains('/simulation') && !def.includesWhatIf) {
            return '/app/billing';
          }
          if (loc.contains('/executive-report') &&
              !def.includesCopilot &&
              !def.includesEsgCompliance) {
            return '/app/billing';
          }
          if (loc.contains('/control-tower') && !def.includesPredictiveAi) {
            return '/app/billing';
          }
          if (loc.contains('/forecasting') && !def.includesPredictiveAi) {
            return '/app/billing';
          }
          if (loc == '/app/reports' || loc.startsWith('/app/reports/')) {
            if (!def.includesEsgCompliance) return '/app/billing';
          }
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/factory-audit',
        redirect: (context, state) => '/factory-score',
      ),
      ShellRoute(
        builder: (context, state, child) => WebsiteLayout(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomePage()),
          ),
          GoRoute(
            path: '/features',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: FeaturesPage()),
          ),
          GoRoute(
            path: '/pricing',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: PricingPage()),
          ),
          GoRoute(
            path: '/contact',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ContactPage()),
          ),
          GoRoute(
            path: '/faq',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: FaqPage()),
          ),
          GoRoute(
            path: '/privacy',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: LegalPage(type: LegalType.privacy),
            ),
          ),
          GoRoute(
            path: '/terms',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: LegalPage(type: LegalType.terms)),
          ),
          GoRoute(
            path: '/cookies',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: LegalPage(type: LegalType.cookies),
            ),
          ),
          GoRoute(
            path: '/roi-calculator',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: RoiCalculatorPage()),
          ),
          GoRoute(
            path: '/factory-score',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: FactoryAuditPage()),
          ),
          GoRoute(
            path: '/book-demo',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: BookDemoPage()),
          ),
          GoRoute(
            path: '/case-studies',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CaseStudiesPage()),
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: LoginPage()),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: RegisterPage()),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: ForgotPasswordPage()),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: OnboardingPage()),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/app',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DashboardPage()),
            routes: [
              GoRoute(
                path: 'control-tower',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ControlTowerPage()),
              ),
              GoRoute(
                path: 'executive-report',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ExecutiveReportPage()),
              ),
              GoRoute(
                path: 'forecasting',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ForecastingPage()),
              ),
              GoRoute(
                path: 'machines',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: MachinesPage()),
              ),
              GoRoute(
                path: 'orders',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: OrdersPage()),
              ),
              GoRoute(
                path: 'plant-floor',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: PlantFloorPage()),
              ),
              GoRoute(
                path: 'suppliers',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SuppliersPage()),
                routes: [
                  GoRoute(
                    path: ':supplierId',
                    pageBuilder: (context, state) => NoTransitionPage(
                      child: SupplierDetailPage(
                        supplierId: state.pathParameters['supplierId'] ?? '',
                      ),
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'reports',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ReportsPage()),
              ),
              GoRoute(
                path: 'billing',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: BillingPage()),
              ),
              GoRoute(
                path: 'supply',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SupplyDashboardPage()),
              ),
              GoRoute(
                path: 'inventory',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: InventoryPage()),
              ),
              GoRoute(
                path: 'shipments',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ShipmentsPage()),
              ),
              GoRoute(
                path: 'vendor-portal',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: VendorPortalPage()),
              ),
              GoRoute(
                path: 'offline-sync',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: OfflineSyncPage()),
              ),
              GoRoute(
                path: 'simulation',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SimulationPage()),
              ),
              GoRoute(
                path: 'settings',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SettingsPage()),
              ),
              GoRoute(
                path: 'team',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: TeamPage()),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/loading',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: _LoadingPage()),
      ),
      GoRoute(
        path: '/404',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: _NotFoundPage()),
      ),
    ],
    errorBuilder: (context, state) => const _NotFoundPage(),
  );
});

class _LoadingPage extends StatelessWidget {
  const _LoadingPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('404', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text('Go home'),
            ),
          ],
        ),
      ),
    );
  }
}
