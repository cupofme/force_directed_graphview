// ignore_for_file: public_member_api_docs
import 'dart:ui';

import 'package:force_directed_graphview/force_directed_graphview.dart';
import 'package:vector_math/vector_math_64.dart';

extension OffsetExtension on Offset {
  Vector2 toVector2() => Vector2(dx, dy);
}

extension QuadExtension on Quad {
  Rect toRect() => Rect.fromLTRB(
        point0.x,
        point0.y,
        point2.x,
        point2.y,
      );
}

extension RectExtension on Rect {
  bool containsNode(Node node, Offset position) {
    final nodeRect = Rect.fromCircle(
      center: position,
      radius: node.size / 2,
    );

    return nodeRect.overlaps(this);
  }

  /// Scale the rect from the center
  Rect scale(double scale) {
    final center = this.center;
    final size = this.size * scale;

    return Rect.fromCenter(
      center: center,
      width: size.width,
      height: size.height,
    );
  }

  bool containsRect(Rect rect) {
    return contains(rect.topLeft) &&
        contains(rect.topRight) &&
        contains(rect.bottomLeft) &&
        contains(rect.bottomRight);
  }
}
