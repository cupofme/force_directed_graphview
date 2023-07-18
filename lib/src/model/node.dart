import 'package:meta/meta.dart';

/// Base class for all nodes
abstract base class NodeBase {
  /// {@nodoc}
  const NodeBase({
    required this.size,
  });

  /// The size of the node. Node bounding box always has a square shape
  /// for the sake of layout simplicity,
  /// but it's visual representation can be anything.
  final double size;
}

/// Default implementation of [NodeBase]
@immutable
final class Node<T> extends NodeBase {
  /// {@nodoc}
  const Node({
    required this.data,
    required super.size,
  });

  /// The data associated with this node, should be unique.
  /// The [Object] type is used instead of generic to allow more widget to be
  /// constant and thus prevent unnecessary rebuilds.
  final T data;

  @override
  int get hashCode => data.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Node && runtimeType == other.runtimeType && data == other.data;
}
