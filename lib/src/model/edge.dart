import 'package:flutter/foundation.dart';
import 'package:force_directed_graphview/force_directed_graphview.dart';

/// Model that represents a edge in the graph.
@immutable
class Edge {
  /// {@nodoc}
  const Edge(
    this.source,
    this.destination, {
    this.data,
  });

  /// Start node of the edge
  final Node source;

  /// End node of the edge
  final Node destination;

  /// Value associated with this edge. Intentionally has type Object?
  /// to not overcomplicate the api
  final Object? data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Edge &&
          runtimeType == other.runtimeType &&
          source == other.source &&
          destination == other.destination &&
          data == other.data;

  @override
  int get hashCode => source.hashCode ^ destination.hashCode;
}
