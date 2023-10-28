import 'package:force_directed_graphview/force_directed_graphview.dart';
import 'package:meta/meta.dart';

/// Base class for all edges
abstract base class EdgeBase<N extends NodeBase> {
  /// {@nodoc}
  const EdgeBase({
    required this.source,
    required this.destination,
  });

  /// Start node of the edge
  final N source;

  /// End node of the edge
  final N destination;

  /// Copies the edge with the given nodes.
  EdgeBase<N> replaceNode({
    N? source,
    N? destination,
  });
}

/// Model that represents a edge in the graph.
@immutable
final class Edge<N extends NodeBase, T> extends EdgeBase<N> {
  /// {@nodoc}
  const Edge({
    required super.source,
    required super.destination,
    required this.data,
  });

  /// Value associated with this edge
  final T data;

  @override
  int get hashCode => source.hashCode ^ destination.hashCode ^ data.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Edge &&
          runtimeType == other.runtimeType &&
          source == other.source &&
          destination == other.destination &&
          data == other.data;

  @override
  Edge<N, T> replaceNode({
    N? source,
    N? destination,
  }) {
    return Edge<N, T>(
      data: data,
      source: source ?? this.source,
      destination: destination ?? this.destination,
    );
  }
}
