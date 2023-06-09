import 'package:flutter/widgets.dart';
import 'package:force_directed_graphview/force_directed_graphview.dart';

/// Builder for the graph layout. Used to manipulate a mutable graph structure
/// and the build an immutable [GraphLayout] instance.
class GraphLayoutBuilder {
  /// {@nodoc}
  GraphLayoutBuilder({
    required this.nodes,
    required this.edges,
  });

  /// {@nodoc}
  final Set<Node> nodes;

  /// {@nodoc}
  final Set<Edge> edges;

  final _positions = <Node, Offset>{};

  /// Returns the position of the node.
  Offset getNodePosition(Node node) => _positions[node]!;

  /// Sets the position of the node.
  void setNodePosition(Node node, Offset position) =>
      _positions[node] = position;

  /// Moves the node by the given delta.
  void translateNode(Node node, Offset delta) {
    _positions[node] = _positions[node]! + delta;
  }

  /// Builds the [GraphLayout] instance.
  GraphLayout build() {
    if (nodes.length != _positions.length) {
      throw StateError('Not all nodes have position');
    }

    return GraphLayout._(
      Map.unmodifiable(_positions),
    );
  }
}

/// Layout of the graph. Contains the positions of all nodes.
@immutable
class GraphLayout {
  const GraphLayout._(this._nodePositions);

  final Map<Node, Offset> _nodePositions;

  /// Returns a node position in layout
  Offset getPosition(Node node) => getPositionOrNull(node)!;

  /// Returns a node position in layout if the position exists,
  /// returns null otherwise
  Offset? getPositionOrNull(Node node) => _nodePositions[node];

  /// Checks if position for node exists in the layout
  bool hasPosition(Node node) => _nodePositions.containsKey(node);
}
