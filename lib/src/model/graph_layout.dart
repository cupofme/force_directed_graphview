import 'dart:ui';

import 'package:force_directed_graphview/force_directed_graphview.dart';

class GraphLayoutBuilder {
  GraphLayoutBuilder({
    required this.nodes,
    required this.edges,
  });

  final Set<Node> nodes;

  final Set<Edge> edges;

  final _nodePositions = <Node, Offset>{};

  Offset getNodePosition(Node node) => _nodePositions[node]!;

  void setNodePosition(Node node, Offset position) => _nodePositions[node] = position;

  void translateNode(Node node, Offset delta) {
    _nodePositions[node] = _nodePositions[node]! + delta;
  }

  GraphLayout build() {
    if (nodes.length != _nodePositions.length) {
      throw StateError('Not all nodes have position');
    }

    return GraphLayout._(
      Map.from(_nodePositions),
    );
  }
}

class GraphLayout {
  GraphLayout._(this._nodePositions);

  final Map<Node, Offset> _nodePositions;

  Offset getPosition(Node node) => getPositionOrNull(node)!;

  Offset? getPositionOrNull(Node node) => _nodePositions[node];

  bool hasPosition(Node node) => _nodePositions.containsKey(node);
}
