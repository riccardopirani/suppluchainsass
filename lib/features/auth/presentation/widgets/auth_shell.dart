import 'package:fabricos/features/website/presentation/widgets/language_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

const _kAuthBgVideoAsset = 'assets/15561210_1920_1080_25fps.mp4';

class _AuthBackgroundVideo extends StatefulWidget {
  const _AuthBackgroundVideo();

  @override
  State<_AuthBackgroundVideo> createState() => _AuthBackgroundVideoState();
}

class _AuthBackgroundVideoState extends State<_AuthBackgroundVideo> {
  VideoPlayerController? _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(_kAuthBgVideoAsset)
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _ready = true);
        _controller?.play();
      }).catchError((_) {
        if (mounted) setState(() => _ready = false);
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return const ColoredBox(color: Color(0xFF030712));
    }
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller!.value.size.width,
          height: _controller!.value.size.height,
          child: VideoPlayer(_controller!),
        ),
      ),
    );
  }
}

class AuthPageShell extends ConsumerWidget {
  const AuthPageShell({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.bullets,
    required this.form,
    this.formMaxWidth = 460,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final List<({IconData icon, String text})> bullets;
  final Widget form;
  final double formMaxWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: _AuthBackgroundVideo()),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.48),
                      Colors.black.withValues(alpha: 0.58),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final split =
                        constraints.maxWidth >= 1040 &&
                            constraints.maxHeight >= 760;
                    if (split) {
                      return Row(
                        children: [
                          Expanded(
                            flex: 11,
                            child: _PaneScroll(
                              child: _HeroPane(
                                eyebrow: eyebrow,
                                title: title,
                                subtitle: subtitle,
                                bullets: bullets,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 9,
                            child: _PaneScroll(
                              child: _FormPane(
                                form: form,
                                maxWidth: formMaxWidth,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          _HeroPane(
                            eyebrow: eyebrow,
                            title: title,
                            subtitle: subtitle,
                            bullets: bullets,
                            compact: true,
                          ),
                          _FormPane(
                            form: form,
                            maxWidth: formMaxWidth,
                            compact: true,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Positioned(
                  top: 4,
                  right: 8,
                  child: LanguageSelector(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaneScroll extends StatelessWidget {
  const _PaneScroll({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: child,
          ),
        );
      },
    );
  }
}

class _HeroPane extends StatelessWidget {
  const _HeroPane({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.bullets,
    this.compact = false,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final List<({IconData icon, String text})> bullets;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            compact ? 20 : 56,
            compact ? 28 : 56,
            compact ? 20 : 40,
            compact ? 28 : 56,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x142563EB),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0x332563EB)),
                ),
                child: Text(
                  eyebrow,
                  style: GoogleFonts.ibmPlexSans(
                    color: const Color(0xFF93C5FD),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  color: const Color(0xFFF9FAFB),
                  fontSize: compact ? 34 : 58,
                  fontWeight: FontWeight.w800,
                  height: 1.04,
                  letterSpacing: -1.0,
                  shadows: const [
                    Shadow(
                      color: Color(0x88000000),
                      blurRadius: 16,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Text(
                  subtitle,
                  style: GoogleFonts.ibmPlexSans(
                    color: const Color(0xFFE2E8F0),
                    fontSize: compact ? 17 : 19,
                    height: 1.65,
                    shadows: const [
                      Shadow(
                        color: Color(0x77000000),
                        blurRadius: 12,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: bullets
                    .map(
                      (bullet) =>
                          _BulletChip(icon: bullet.icon, text: bullet.text),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormPane extends StatelessWidget {
  const _FormPane({
    required this.form,
    required this.maxWidth,
    this.compact = false,
  });

  final Widget form;
  final double maxWidth;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 16 : 24,
        vertical: compact ? 24 : 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: form,
        ),
      ),
    );
  }
}

class _BulletChip extends StatelessWidget {
  const _BulletChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x22FFFFFF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF93C5FD)),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.ibmPlexSans(
              color: const Color(0xFFF9FAFB),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
