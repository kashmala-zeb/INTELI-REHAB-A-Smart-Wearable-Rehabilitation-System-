// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

Widget build3DViewer({
  required double armAngle,
  required double elbowFlex,
  required double bicepsPct,
  required double deltoidPct,
  required double forearmPct,
  required int romDeg,
  required double rotY,
  required double rotX,
  required double zoom,
}) {
  // We use a unique viewType for each model view instance
  const String viewType = 'model-viewer-3d-digital-twin';
  
  // Register the model-viewer HTML custom element
  ui_web.platformViewRegistry.registerViewFactory(
    viewType,
    (int viewId) {
      final element = html.Element.tag('model-viewer')
        ..setAttribute('src', 'assets/assets/models/Ch22_nonPBR.glb')
        ..setAttribute('camera-controls', '')
        ..setAttribute('interaction-prompt', 'none')
        ..setAttribute('shadow-intensity', '0.6')
        ..setAttribute('exposure', '1.1')
        ..setAttribute('camera-orbit', '${rotY}deg ${rotX + 75}deg ${110 * zoom}%')
        ..setAttribute('field-of-view', '35deg')
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.border = 'none'
        ..style.backgroundColor = 'transparent';
      return element;
    },
  );

  return const HtmlElementView(viewType: viewType);
}
