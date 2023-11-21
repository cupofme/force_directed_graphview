import 'package:flutter/widgets.dart';
import 'package:force_directed_graphview/src/model/edge.dart';
import 'package:force_directed_graphview/src/model/node.dart';

/// Interface for painting edges.
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

/// Interface for painting animated edges.
abstract interface class AnimatedEdgePainter<N extends NodeBase,
    E extends EdgeBase<N>> implements EdgePainter<N, E> {
  /// Animation used to paint the edge.
  Animation<double> get animation;
}
