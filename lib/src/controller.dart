part of 'graph_view.dart';

/// Controller to manipulate the [GraphView].
class GraphController<N extends NodeBase, E extends EdgeBase<N>>
    with ChangeNotifier {
  final _nodes = <N>{};
  final _edges = <E>{};

  GraphLayout? _layout;

  // Region of canvas that is building its nodes now
  Rect? _effectiveViewport;
  Rect? _actualViewport;
  GraphLayoutAlgorithm? _currentAlgorithm;
  LazyBuilding? _lazyBuilding;
  TransformationController? _transformationController;
  GraphCanvasSize? _size;

  Size? _currentSize;
  var _centered = false;

  /// {@nodoc}
  Set<N> get nodes => Set.unmodifiable(_nodes);

  /// {@nodoc}
  Set<E> get edges => Set.unmodifiable(_edges);

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

  /// Updates the graph using [GraphMutator]. Initiates relayout.
  void mutate(void Function(GraphMutator<N, E> mutator) callback) {
    callback(GraphMutator<N, E>(this));
    _currentSize = _size?.resolve(nodes: nodes, edges: edges);
    _relayout();
  }

  /// Returns s set of nodes that are currently visible on the screen
  /// according to the provided [LazyBuilding].
  Set<N> getVisibleNodes() {
    final viewport = _effectiveViewport;
    final layout = _layout;
    if (viewport == null || layout == null) return {};
    if (viewport == Rect.largest) return nodes;

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

  /// {@nodoc}
  void jumpToCenter() {
    jumpToPosition(canvasSize.center(Offset.zero));
  }

  /// Instantly jumps to the given position on canvas
  void jumpToPosition(Offset position) {
    final controller = _transformationController;
    final layout = _layout;
    final viewport = _actualViewport;
    if (controller == null || layout == null || viewport == null) {
      return;
    }

    final oldMatrix = controller.value.clone();
    final matrixScale = oldMatrix.getMaxScaleOnAxis();
    final matrixOffset =
        -Offset(oldMatrix.storage[12], oldMatrix.storage[13]) / matrixScale;
    final center = viewport.center;

    controller.value = Matrix4.identity()
      ..scale(matrixScale)
      ..translate(-position.dx, -position.dy)
      ..translate(
        (center.dx - matrixOffset.dx),
        (center.dy - matrixOffset.dy),
      );
  }

  /// Instantly jumps to the given node placing it in the center of the screen.
  FutureOr<void> jumpToNode(N node) async {
    if (!_hasNode(node)) {
      throw ArgumentError.value(node, 'node', 'Node is not in the graph');
    }

    if (_layout == null) {
      await Future<void>.delayed(Duration.zero);

      if (_layout == null) {
        throw StateError('Graph is not laid out yet');
      }
    }
    jumpToPosition(_layout!.getPosition(node));
  }

  /// Instantly zoom in by a given factor.
  void zoomIn([double factor = 1.2]) => zoomBy(factor);

  /// Instantly zoom out by a given factor.
  void zoomOut([double factor = 1 / 1.2]) => zoomBy(factor);

  /// Instantly zooms by a given factor.
  void zoomBy(double factor) {
    if (factor <= 0) {
      throw ArgumentError.value(factor, 'factor', 'Factor must be > 0');
    }

    final controller = _transformationController;
    final viewport = _actualViewport;
    if (controller == null || viewport == null) {
      return;
    }

    final oldMatrix = controller.value.clone();
    final center = viewport.center;

    controller.value = oldMatrix
      ..translate(center.dx, center.dy)
      ..scale(factor)
      ..translate(-center.dx, -center.dy);
  }

  /// {@nodoc}
  void replaceNode(N node, N newNode) {
    _replaceNode(node, newNode);
  }

  /// {@nodoc}
  void setPinned(N node, bool pinned) {
    _replaceNode(node, node.copyWithPinned(pinned) as N);
  }

  Future<void> _relayout() async {
    final currentAlgorithm = _currentAlgorithm;
    final currentSize = _currentSize;
    final layout = _layout;

    if (currentAlgorithm == null || currentSize == null || layout == null) {
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

  Future<void> _applyConfiguration({
    required GraphLayoutAlgorithm algorithm,
    required GraphCanvasSize size,
    required LazyBuilding lazyBuilding,
    required TransformationController transformationController,
  }) async {
    _lazyBuilding = lazyBuilding;
    _transformationController = transformationController;
    _currentAlgorithm = algorithm;
    _size = size;
    _currentSize = _size?.resolve(nodes: nodes, edges: edges);
    final layoutStream = algorithm.layout(
      nodes: _nodes,
      edges: _edges,
      size: canvasSize,
    );

    await for (final layout in layoutStream) {
      _layout = layout;

      if (!_centered) {
        jumpToCenter();
        _centered = true;
      }
      notifyListeners();
    }
  }

  void _updateViewport(Quad viewport) {
    _actualViewport = viewport.toRect();
    final actualViewport = _actualViewport = viewport.toRect();
    final newEffectiveViewport = switch (_lazyBuilding) {
      LazyBuildingViewport(scale: final scale) => actualViewport.scale(scale),
      LazyBuildingNone() || null => Rect.largest,
    };

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

  void _addNode(N node) {
    if (_hasNode(node)) {
      throw StateError('Node is already in the graph');
    }
    _nodes.add(node);
  }

  void _removeNode(N node) {
    if (!_hasNode(node)) {
      throw StateError('Node $node is not in the graph');
    }
    _edges
        .removeWhere((edge) => edge.source == node || edge.destination == node);
    _nodes.remove(node);
  }

  void _addEdge(E edge) {
    if (!_hasNode(edge.source) || !_hasNode(edge.destination)) {
      throw StateError('Source or destination node is not in the graph');
    }
    _edges.add(edge);
  }

  void _removeEdge(E edge) {
    if (!_hasEdge(edge)) {
      throw StateError('Edge $edge is not in the graph');
    }
    _edges.remove(edge);
  }

  /// Pins or unpins the node. Pinned nodes should not be affected by layout.
  void _replaceNode(N node, N newNode) {
    if (!_hasNode(node)) {
      throw ArgumentError.value(node, 'node', 'Node is not in the graph');
    }

    _nodes
      ..remove(node)
      ..add(newNode);

    if (_layout != null) {
      final position = _layout!.getPosition(node);
      final builder = GraphLayoutBuilder.fromLayout(_layout!)
        ..removeNode(node)
        ..addNode(newNode)
        ..setNodePosition(newNode, position);
      _layout = builder.build();
    }

    final edgesCopy = Set.of(_edges);

    for (final edge in edgesCopy) {
      if (edge.source == node) {
        _edges
          ..remove(edge)
          ..add(edge.replaceNode(source: newNode) as E);
      }
      if (edge.destination == node) {
        _edges
          ..remove(edge)
          ..add(edge.replaceNode(destination: newNode) as E);
      }
    }

    notifyListeners();
  }

  /// {@nodoc}
  void clear() {
    _nodes.clear();
    _edges.clear();
    _layout = const GraphLayout.empty();
    notifyListeners();
  }

  bool _hasNode(N node) => _nodes.contains(node);

  bool _hasEdge(E edge) => _edges.contains(edge);
}

/// Wrapper around [GraphController] that allows
/// changing the graph in a batch to avoid unnecessary rebuilds.
class GraphMutator<N extends NodeBase, E extends EdgeBase<N>> {
  /// {@nodoc}
  GraphMutator(this.controller);

  /// {@nodoc}
  final GraphController controller;

  /// {@nodoc}
  void addNode(N node) {
    controller._addNode(node);
  }

  /// {@nodoc}
  void addEdge(E edge) {
    controller._addEdge(edge);
  }

  /// {@nodoc}
  void removeNode(N node) {
    controller._removeNode(node);
  }

  /// {@nodoc}
  void removeEdge(E edge) {
    controller._removeEdge(edge);
  }

  /// {@nodoc}
  void clear() {
    controller.clear();
  }
}
