import 'package:flutter/foundation.dart';
import 'package:force_directed_graphview/src/model/node.dart';

/// Model that represents a edge in the graph.
@immutable
class Edge {
  /// {@nodoc}
  const Edge(
    this.source,
    this.target,
  );

  /// Start node of the edge
  final Node source;

  /// End node of the edge
  final Node target;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Edge &&
          runtimeType == other.runtimeType &&
          source == other.source &&
          target == other.target;

  @override
  int get hashCode => source.hashCode ^ target.hashCode;
}
