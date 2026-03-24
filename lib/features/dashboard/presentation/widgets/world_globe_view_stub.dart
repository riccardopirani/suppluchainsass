import 'package:flutter/material.dart';

class WorldGlobeView extends StatelessWidget {
  const WorldGlobeView({super.key, required this.points});

  final List<Map<String, dynamic>> points;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      ),
      child: const Center(
        child: Text('3D globe available on web build.'),
      ),
    );
  }
}
