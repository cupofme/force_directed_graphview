part of 'graph_view.dart';

class GraphController with ChangeNotifier {
  final _nodes = <Node>{};
  final _edges = <Edge>{};

  GraphLayout? _layout;
  Size? _currentSize;
  GraphLayoutAlgorithm? _currentAlgorithm;
  Rect? _effectiveViewport;

  Set<Node> get nodes => Set.unmodifiable(_nodes);
  Set<Edge> get edges => Set.unmodifiable(_edges);
  GraphLayout get layout =>
      _layout ?? (throw StateError('Graph is not laid out yet'));
  bool get hasLayout => _layout != null;

  void mutate(void Function(GraphMutator mutator) callback) {
    callback(GraphMutator(this));
    notifyListeners();
    _relayout();
  }

  Set<Node> getVisibleNodes() {
    final viewport = _effectiveViewport;
    final layout = _layout;
    if (viewport == null || layout == null) {
      return {};
    }

    return _nodes.where(
      (node) {
        if (!layout.hasPosition(node)) return false;
        return viewport.containsNode(
          node,
          layout.getPosition(node),
        );
      },
    ).toSet();
  }

  Future<void> _relayout() async {
    final currentAlgorithm = _currentAlgorithm;
    final currentSize = _currentSize;

    if (currentAlgorithm == null || currentSize == null) {
      return;
    }

    final layoutStream = currentAlgorithm.relayout(
      existingLayout: layout,
      nodes: nodes,
      edges: _edges,
      size: currentSize,
    );

    await for (final layout in layoutStream) {
      _layout = layout;
      notifyListeners();
    }
  }

  Future<void> _applyLayout(GraphLayoutAlgorithm algorithm, Size size) async {
    _currentAlgorithm = algorithm;
    _currentSize = size;

    final layoutStream = algorithm.layout(
      nodes: nodes,
      edges: _edges,
      size: size,
    );

    await for (final layout in layoutStream) {
      _layout = layout;
      notifyListeners();
    }
  }

  void _updateViewport(Quad viewport) {
    final actualViewport = viewport.toRect();
    // todo: configure margin
    final newEffectiveViewport = actualViewport.scale(1.2);

    if (_effectiveViewport != null &&
        _effectiveViewport!.containsRect(actualViewport)) {
      return;
    } else {
      _effectiveViewport = newEffectiveViewport;
      notifyListeners();
    }
  }

  void _addNode(Node node) {
    if (_hasNode(node)) {
      throw StateError('Node is already in the graph');
    }
    _nodes.add(node);
  }

  void _removeNode(Node node) {
    if (!_hasNode(node)) {
      throw StateError('Node $node is not in the graph');
    }
    _nodes.remove(node);
    _edges.removeWhere((edge) => edge.source == node || edge.target == node);
  }

  void _addEdge(Edge edge) {
    if (!_hasNode(edge.source) || !_hasNode(edge.target)) {
      throw StateError('Source or target node is not in the graph');
    }
    _edges.add(edge);
  }

  void _removeEdge(Edge edge) {
    if (!_hasEdge(edge)) {
      throw StateError('Edge $edge is not in the graph');
    }
    _edges.remove(edge);
  }

  bool _hasNode(Node node) => _nodes.any((n) => n == node);

  bool _hasEdge(Edge edge) => _edges.any((e) => e == edge);
}

/// Wrapper around [GraphController] that allows
/// changing the graph in a batch to avoid unnecessary rebuilds.
class GraphMutator {
  final GraphController controller;

  GraphMutator(this.controller);

  void addNode(Node node) {
    controller._addNode(node);
  }

  void addEdge(Edge edge) {
    controller._addEdge(edge);
  }

  void removeNode(Node node) {
    controller._removeNode(node);
  }

  void removeEdge(Edge edge) {
    controller._removeEdge(edge);
  }
}
