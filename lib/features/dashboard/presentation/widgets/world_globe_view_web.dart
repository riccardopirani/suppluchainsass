// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';

class WorldGlobeView extends StatefulWidget {
  const WorldGlobeView({super.key, required this.points});

  final List<Map<String, dynamic>> points;

  @override
  State<WorldGlobeView> createState() => _WorldGlobeViewState();
}

class _WorldGlobeViewState extends State<WorldGlobeView> {
  late final String _viewType;
  late final html.IFrameElement _iframe;

  @override
  void initState() {
    super.initState();
    _viewType = 'fabricos-world-globe-${DateTime.now().microsecondsSinceEpoch}';
    _iframe = html.IFrameElement()
      ..style.border = '0'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allow = 'fullscreen';

    _updateSrc();

    ui.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      return _iframe;
    });
  }

  @override
  void didUpdateWidget(covariant WorldGlobeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (jsonEncode(oldWidget.points) != jsonEncode(widget.points)) {
      _updateSrc();
    }
  }

  void _updateSrc() {
    final markersJson = Uri.encodeComponent(jsonEncode(widget.points));
    _iframe.src = Uri.base
        .resolve('cesium_globe.html?markers=$markersJson')
        .toString();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}
