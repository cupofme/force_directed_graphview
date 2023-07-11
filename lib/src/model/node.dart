import 'package:flutter/foundation.dart';

/// Model that represents a node in the graph.
@immutable
class Node {
  /// {@nodoc}
  const Node({
    required this.data,
    required this.size,
  });

  /// The data associated with this node, should be unique.
  /// The [Object] type is used instead of generic to allow more widget to be
  /// constant and thus prevent unnecessary rebuilds.
  final Object data;

  /// The size of the node. Node will be placed in the center of the size.
  /// Node always has a square shape for the sake of layout simplicity,
  /// but it's visual representation can be anything.
  final double size;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Node &&
          runtimeType == other.runtimeType &&
          data == other.data &&
          size == other.size;

  @override
  int get hashCode => data.hashCode ^ size.hashCode;
}
