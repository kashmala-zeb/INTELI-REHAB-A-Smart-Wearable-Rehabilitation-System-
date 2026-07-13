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
  // Return a simple Container so the caller knows to fallback to 2D CustomPaint
  return const SizedBox.shrink();
}
