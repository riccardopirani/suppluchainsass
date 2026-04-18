import 'dart:async';
import 'dart:html' as html;

import 'package:fabricos/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Widget wrapWebsiteExitIntent({
  required Widget child,
  VoidCallback? onBookDemo,
  VoidCallback? onRoi,
}) =>
    _ExitIntentScope(
      onBookDemo: onBookDemo,
      onRoi: onRoi,
      child: child,
    );

class _ExitIntentScope extends StatefulWidget {
  const _ExitIntentScope({
    required this.child,
    this.onBookDemo,
    this.onRoi,
  });

  final Widget child;
  final VoidCallback? onBookDemo;
  final VoidCallback? onRoi;

  @override
  State<_ExitIntentScope> createState() => _ExitIntentScopeState();
}

class _ExitIntentScopeState extends State<_ExitIntentScope> {
  StreamSubscription<html.MouseEvent>? _sub;
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    _sub = html.document.onMouseLeave.listen((_) {
      if (_shown || !mounted) return;
      _shown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final l10n = context.l10n;
        showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF0F172A),
            title: Text(
              l10n.t('pub_exit_title'),
              style: const TextStyle(color: Color(0xFFF9FAFB)),
            ),
            content: Text(
              l10n.t('pub_exit_body'),
              style: const TextStyle(color: Color(0xFF9CA3AF)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.t('pub_exit_dismiss')),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  widget.onRoi?.call();
                  ctx.go('/roi-calculator');
                },
                child: Text(l10n.t('pub_mfg_cta_roi')),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  widget.onBookDemo?.call();
                  ctx.go('/book-demo');
                },
                child: Text(l10n.t('pub_mfg_cta_demo')),
              ),
            ],
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
