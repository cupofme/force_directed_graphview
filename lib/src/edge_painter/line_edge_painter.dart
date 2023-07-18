import 'package:flutter/material.dart';
import 'package:force_directed_graphview/force_directed_graphview.dart';

/// A painter for painting edges as lines. Draws a straight line between
@immutable
final class LineEdgePainter<N extends NodeBase, E extends EdgeBase<N>>
    implements EdgePainter<N, E> {
  /// {@nodoc}
  const LineEdgePainter({
    this.thickness = 1.0,
    this.color = Colors.black,
  });

  /// Thickness of the line.
  final double thickness;

  /// Color of the line.
  final Color color;

  @override
  void paint(
    Canvas canvas,
    E edge,
    Offset sourcePosition,
    Offset destinationPosition,
  ) {
    canvas.drawLine(
      sourcePosition,
      destinationPosition,
      Paint()
        ..color = color
        ..strokeWidth = thickness,
    );
  }
}
