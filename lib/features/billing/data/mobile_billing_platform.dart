import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Native iOS / Android builds use StoreKit / Play Billing instead of Stripe Checkout URLs.
bool get kUseMobileStoreBilling =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android);
