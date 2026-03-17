import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stockguard_ai/features/auth/presentation/login_page.dart';
import 'package:stockguard_ai/features/auth/presentation/register_page.dart';
import 'package:stockguard_ai/features/auth/presentation/forgot_password_page.dart';
import 'package:stockguard_ai/features/website/presentation/home_page.dart';
import 'package:stockguard_ai/features/website/presentation/website_layout.dart';
import 'package:stockguard_ai/features/website/presentation/pricing_page.dart';
import 'package:stockguard_ai/features/website/presentation/features_page.dart';
import 'package:stockguard_ai/features/website/presentation/contact_page.dart';
import 'package:stockguard_ai/features/website/presentation/legal_page.dart';
import 'package:stockguard_ai/features/website/presentation/faq_page.dart';
import 'package:stockguard_ai/features/app_shell/app_shell.dart';
import 'package:stockguard_ai/features/dashboard/presentation/dashboard_page.dart';
import 'package:stockguard_ai/features/onboarding/presentation/onboarding_page.dart';
import 'package:stockguard_ai/features/products/presentation/products_page.dart';
import 'package:stockguard_ai/features/products/presentation/product_detail_page.dart';
import 'package:stockguard_ai/features/reorder/presentation/reorder_suggestions_page.dart';
import 'package:stockguard_ai/features/forecasting/presentation/forecasting_page.dart';
import 'package:stockguard_ai/features/suppliers/presentation/suppliers_page.dart';
import 'package:stockguard_ai/features/alerts/presentation/alerts_page.dart';
import 'package:stockguard_ai/features/purchase_orders/presentation/purchase_orders_page.dart';
import 'package:stockguard_ai/features/analytics/presentation/analytics_page.dart';
import 'package:stockguard_ai/features/billing/presentation/billing_page.dart';
import 'package:stockguard_ai/features/settings/presentation/settings_page.dart';
import 'package:stockguard_ai/features/warehouses/presentation/warehouses_page.dart';
import 'package:stockguard_ai/features/auth/providers/auth_provider.dart';
import 'package:stockguard_ai/localization/app_localizations.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // Se lo stream di auth è ancora in caricamento, mostra loading
      if (authState.isLoading) {
        return '/loading';
      }
      
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register') ||
          state.matchedLocation.startsWith('/forgot-password');
      final isAppRoute = state.matchedLocation.startsWith('/app');

      if (isAppRoute && !isLoggedIn) {
        return '/login';
      }
      if (isAuthRoute && isLoggedIn) {
        return '/app';
      }
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => WebsiteLayout(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomePage(),
            ),
          ),
          GoRoute(
            path: '/features',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FeaturesPage(),
            ),
          ),
          GoRoute(
            path: '/pricing',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PricingPage(),
            ),
          ),
          GoRoute(
            path: '/contact',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ContactPage(),
            ),
          ),
          GoRoute(
            path: '/faq',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FaqPage(),
            ),
          ),
          GoRoute(
            path: '/privacy',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: LegalPage(type: LegalType.privacy),
            ),
          ),
          GoRoute(
            path: '/terms',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: LegalPage(type: LegalType.terms),
            ),
          ),
          GoRoute(
            path: '/cookies',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: LegalPage(type: LegalType.cookies),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: LoginPage(),
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: RegisterPage(),
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: ForgotPasswordPage(),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: OnboardingPage(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/app',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardPage(),
            ),
            routes: [
              GoRoute(
                path: 'products',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ProductsPage(),
                ),
              ),
              GoRoute(
                path: 'products/:id',
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return NoTransitionPage(
                    child: ProductDetailPage(productId: id),
                  );
                },
              ),
              GoRoute(
                path: 'reorder',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ReorderSuggestionsPage(),
                ),
              ),
              GoRoute(
                path: 'forecasting',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ForecastingPage(),
                ),
              ),
              GoRoute(
                path: 'suppliers',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: SuppliersPage(),
                ),
              ),
              GoRoute(
                path: 'alerts',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: AlertsPage(),
                ),
              ),
              GoRoute(
                path: 'purchase-orders',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: PurchaseOrdersPage(),
                ),
              ),
              GoRoute(
                path: 'analytics',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: AnalyticsPage(),
                ),
              ),
              GoRoute(
                path: 'billing',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: BillingPage(),
                ),
              ),
              GoRoute(
                path: 'settings',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: SettingsPage(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/loading',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: _LoadingPage(),
        ),
      ),
      GoRoute(
        path: '/404',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: _NotFoundPage(),
        ),
      ),
    ],
    errorBuilder: (context, state) => const _NotFoundPage(),
  );
});

class _LoadingPage extends StatelessWidget {
  const _LoadingPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
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
              child: Builder(
                builder: (ctx) => Text(AppLocalizations.of(ctx)?.translate('go_home') ?? 'Go home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
