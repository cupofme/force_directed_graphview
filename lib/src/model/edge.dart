import 'package:equatable/equatable.dart';
import 'package:force_directed_graphview/force_directed_graphview.dart';
import 'package:meta/meta.dart';

/// Model that represents a edge in the graph.
@immutable
class Edge with EquatableMixin {
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
  List<Object?> get props => [source, destination, data];
}
