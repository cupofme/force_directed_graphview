import 'package:flutter/material.dart';
import 'package:force_directed_graphview/force_directed_graphview.dart';

/// A painter for drawing a moving dash line between nodes.
@immutable
final class AnimatedDashEdgePainter<N extends NodeBase, E extends EdgeBase<N>>
    implements AnimatedEdgePainter<N, E> {
  /// { @nodoc }
  const AnimatedDashEdgePainter({
    required this.animation,
    this.thickness = 1.0,
    this.color = Colors.black,
    this.dashLength = 10.0,
    this.dashSpacing = 10.0,
  });

  /// { @nodoc }
  final double thickness;

  /// { @nodoc }
  final double dashLength;

  /// { @nodoc }
  final double dashSpacing;

  /// { @nodoc }
  final Color color;

  @override
  final Animation<double> animation;

  @override
  void paint(
    Canvas canvas,
    E edge,
    Offset sourcePosition,
    Offset destinationPosition,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke;

    final delta = destinationPosition - sourcePosition;
    final distance = delta.distance;
    final direction = delta.direction;

    final numberOfDashes = (distance / (dashLength + dashSpacing)).floor();

    final dashDelta = Offset.fromDirection(direction, dashLength);
    final spacingDelta = Offset.fromDirection(direction, dashSpacing);
    final stepDelta = dashDelta + spacingDelta;

    final path = Path()
      ..moveTo(sourcePosition.dx, sourcePosition.dy)
      ..relativeMoveTo(
        stepDelta.dx * animation.value,
        stepDelta.dy * animation.value,
      );

    for (var i = 0; i < numberOfDashes; i++) {
      path
        ..relativeLineTo(dashDelta.dx, dashDelta.dy)
        ..relativeMoveTo(spacingDelta.dx, spacingDelta.dy);
    }

    canvas.drawPath(path, paint);
  }
}
