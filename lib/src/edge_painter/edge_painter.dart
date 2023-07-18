import 'dart:ui';

import 'package:force_directed_graphview/src/model/edge.dart';
import 'package:force_directed_graphview/src/model/node.dart';

/// An interface for painting edges.
abstract interface class EdgePainter<N extends NodeBase,
    E extends EdgeBase<N>> {
  /// Paints the edge between [sourcePosition] and [destinationPosition].
  void paint(
    Canvas canvas,
    E edge,
    Offset sourcePosition,
    Offset destinationPosition,
  );
}
