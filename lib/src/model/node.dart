import 'package:meta/meta.dart';

/// Base class for all nodes
abstract base class NodeBase {
  /// {@nodoc}
  const NodeBase({
    required this.size,
    this.pinned = false,
  });

  /// The size of the node. Node bounding box always has a square shape
  /// for the sake of layout simplicity,
  /// but it's visual representation can be anything.
  final double size;

  /// Specifies whether the node is pinned to its position.
  final bool pinned;

  /// Copies the node with the given pinned value.
  NodeBase copyWithPinned(bool pinned);
}

/// Default implementation of [NodeBase]
@immutable
final class Node<T> extends NodeBase {
  /// {@nodoc}
  const Node({
    required this.data,
    required super.size,
    super.pinned,
  });

  /// The data associated with this node, should be unique.
  final T data;

  @override
  int get hashCode => data.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Node && runtimeType == other.runtimeType && data == other.data;

  @override
  NodeBase copyWithPinned(bool pinned) => copyWith(pinned: pinned);

  /// {@nodoc}
  Node<T> copyWith({
    double? size,
    bool? pinned,
  }) {
    return Node<T>(
      data: data,
      size: size ?? this.size,
      pinned: pinned ?? this.pinned,
    );
  }
}
