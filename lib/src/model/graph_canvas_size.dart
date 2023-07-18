import 'dart:math';
import 'dart:ui';

import 'package:force_directed_graphview/src/model/edge.dart';
import 'package:force_directed_graphview/src/model/node.dart';
import 'package:meta/meta.dart';

/// Defines the size of the graph canvas. Note that this size won't change
/// dynamically after the graph changed,
/// so take the potential graph changes into account.
@immutable
sealed class GraphCanvasSize {
  /// {@macro fixed_graph_view_size}
  const factory GraphCanvasSize.fixed(Size size) = FixedGraphViewSize;

  /// {@macro dynamic_graph_view_size}
  const factory GraphCanvasSize.proportional([double areaFactor]) =
      ProportionalGraphViewSize;

  /// Resolves the size of the graph canvas.
  Size resolve({
    required Set<NodeBase> nodes,
    required Set<EdgeBase> edges,
  });
}

/// {@template fixed_graph_view_size}
/// The size of the graph canvas is fixed.
/// {@endtemplate}
@immutable
class FixedGraphViewSize implements GraphCanvasSize {
  /// {@nodoc}
  const FixedGraphViewSize(this.size);

  /// The fixed size of the graph canvas.
  final Size size;

  @override
  Size resolve({
    required Set<NodeBase> nodes,
    required Set<EdgeBase> edges,
  }) {
    return size;
  }

  @override
  int get hashCode => size.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FixedGraphViewSize &&
          runtimeType == other.runtimeType &&
          size == other.size;
}

/// {@template dynamic_graph_view_size}
/// The area of the graph canvas is defined by the total area of
/// the nodes multiplied by [areaFactor]. The final size is calculated by
/// the square root of the area.
/// {@endtemplate}
@immutable
class ProportionalGraphViewSize implements GraphCanvasSize {
  /// {@macro dynamic_graph_view_size}
  const ProportionalGraphViewSize([this.areaFactor = 10]);

  /// The factor that is used to calculate the size of the graph canvas.
  final double areaFactor;

  @override
  Size resolve({
    required Set<NodeBase> nodes,
    required Set<EdgeBase> edges,
  }) {
    final area = nodes.fold<double>(
      0,
      (area, node) => area + pow(node.size, 2),
    );

    return Size.square(sqrt(area * areaFactor));
  }

  @override
  int get hashCode => areaFactor.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProportionalGraphViewSize &&
          runtimeType == other.runtimeType &&
          areaFactor == other.areaFactor;
}
