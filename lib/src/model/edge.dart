import 'package:equatable/equatable.dart';
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
}

/// Model that represents a edge in the graph.
@immutable
final class Edge<N extends NodeBase> extends EdgeBase<N> with EquatableMixin {
  /// {@nodoc}
  const Edge({
    required super.source,
    required super.destination,
    this.data,
  });

  /// SImple constructor that creates an edge without data
  const Edge.simple(
    N source,
    N destination,
  ) : this(
          source: source,
          destination: destination,
          data: null,
        );

  /// Value associated with this edge. Intentionally has type Object?
  /// to not overcomplicate the api
  final Object? data;

  @override
  List<Object?> get props => [source, destination, data];
}
