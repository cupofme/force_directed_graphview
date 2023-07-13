import 'dart:ui';

import 'package:force_directed_graphview/src/model/edge.dart';

/// An interface for painting edges.
abstract class EdgePainter {
  /// {@nodoc}
  void paint(
    Canvas canvas,
    Edge edge,
    Offset sourcePosition,
    Offset destinationPosition,
  );
}
