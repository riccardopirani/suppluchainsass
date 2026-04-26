import 'package:fabricos/l10n/fabricos_home_arb.dart';
import 'package:flutter/widgets.dart';

/// Public landing copy from ARB (`lib/l10n/app_*.arb`).
///
/// For locales without a dedicated ARB (e.g. `ru`, `zh`), [FabricosHomeArb.of]
/// may be null — falls back to English strings.
extension HomeL10nContext on BuildContext {
  FabricosHomeArb get homeL10n =>
      FabricosHomeArb.of(this) ?? lookupFabricosHomeArb(const Locale('en'));
}
