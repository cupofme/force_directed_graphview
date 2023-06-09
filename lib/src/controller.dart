part of 'graph_view.dart';

/// Controller to manipulate the [GraphView].
class GraphController with ChangeNotifier {
  static const _effectiveViewportScale = 1.2;
  final _nodes = <Node>{};
  final _edges = <Edge>{};

  GraphLayout? _layout;
  Size? _currentSize;
  Rect? _effectiveViewport;
  GraphLayoutAlgorithm? _currentAlgorithm;
  TransformationController? _transformationController;

  /// {@nodoc}
  Set<Node> get nodes => Set.unmodifiable(_nodes);

  /// {@nodoc}
  Set<Edge> get edges => Set.unmodifiable(_edges);

  /// Returns the current layout. Throws [StateError]
  /// if the graph is not laid out yet.
  GraphLayout get layout =>
      _layout ?? (throw StateError('Graph is not laid out yet'));

  /// Return the current size of the graph canvas. Throws [StateError]
  /// if the size is not available yet.
  Size get canvasSize =>
      _currentSize ?? (throw StateError('Size is not available yet'));

  /// Checks whether the graph is laid out and the size is available.
  bool get canLayout => _layout != null && _currentSize != null;

  /// Updates the graph using [GraphMutator]
  void mutate(void Function(GraphMutator mutator) callback) {
    callback(GraphMutator(this));
    _relayout();
  }

  /// Returns s set of nodes that are currently visible on the screen.
  /// Uses 1.2 times the viewport size to determine visibility.
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

  /// Instantly jumps to the given node.
  void jumpToNode(Node node) {
    final controller = _transformationController;
    final layout = _layout;
    final viewport = _effectiveViewport;
    if (controller == null || layout == null || viewport == null) {
      return;
    }

    final position = layout.getPosition(node);
    final matrix = controller.value.clone();
    final center = viewport.scale(1 / _effectiveViewportScale).center;

    matrix
      ..translate(center.dx, center.dy)
      ..translate(-position.dx, -position.dy);

    controller.value = matrix;
  }

  /// Instantly zoom in by a given factor.
  void zoomIn([double factor = 1.2]) => zoomBy(factor);

  /// Instantly zoom out by a given factor.
  void zoomOut([double factor = 1 / 1.2]) => zoomBy(factor);

  /// Instantly zooms by a given factor.
  void zoomBy(double factor) {
    if (factor <= 0) {
      throw ArgumentError.value(
        factor,
        'factor',
        'Factor must be greater than 0',
      );
    }

    final controller = _transformationController;
    final viewport = _effectiveViewport;
    if (controller == null || viewport == null) {
      return;
    }

    final matrix = controller.value.clone();
    final center = viewport.scale(1 / _effectiveViewportScale).center;

    matrix
      ..translate(center.dx, center.dy)
      ..scale(factor)
      ..translate(-center.dx, -center.dy);

    controller.value = matrix;
  }

  // ignore: use_setters_to_change_properties
  void _setTransformationController(TransformationController controller) {
    _transformationController = controller;
  }

  Future<void> _relayout() async {
    final currentAlgorithm = _currentAlgorithm;
    final currentSize = _currentSize;

    if (currentAlgorithm == null || currentSize == null) {
      return;
    }

    final layoutStream = currentAlgorithm.relayout(
      existingLayout: layout,
      nodes: _nodes,
      edges: _edges,
      size: currentSize,
    );

    await for (final layout in layoutStream) {
      _layout = layout;
      notifyListeners();
    }
  }

  Future<void> _applyLayout(
    GraphLayoutAlgorithm algorithm,
    GraphCanvasSize size,
  ) async {
    _currentAlgorithm = algorithm;
    _currentSize = size.resolve(
      nodes: _nodes,
      edges: _edges,
    );

    final layoutStream = algorithm.layout(
      nodes: _nodes,
      edges: _edges,
      size: canvasSize,
    );

    await for (final layout in layoutStream) {
      _layout = layout;
      notifyListeners();
    }
  }

  void _updateViewport(Quad viewport) {
    final actualViewport = viewport.toRect();
    final newEffectiveViewport = actualViewport.scale(_effectiveViewportScale);

    // If the new viewport is contained in the current effective viewport,
    // then skip the update to avoid unnecessary rebuilds
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
    _edges
        .removeWhere((edge) => edge.source == node || edge.destination == node);
    _nodes.remove(node);
  }

  void _addEdge(Edge edge) {
    if (!_hasNode(edge.source) || !_hasNode(edge.destination)) {
      throw StateError('Source or destination node is not in the graph');
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
  /// {@nodoc}
  GraphMutator(this.controller);

  /// {@nodoc}
  final GraphController controller;

  /// {@nodoc}
  void addNode(Node node) {
    controller._addNode(node);
  }

  /// {@nodoc}
  void addEdge(Edge edge) {
    controller._addEdge(edge);
  }

  /// {@nodoc}
  void removeNode(Node node) {
    controller._removeNode(node);
  }

  /// {@nodoc}
  void removeEdge(Edge edge) {
    controller._removeEdge(edge);
  }
}
