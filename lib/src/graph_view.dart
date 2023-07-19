import 'package:flutter/material.dart';
import 'package:force_directed_graphview/force_directed_graphview.dart';
import 'package:force_directed_graphview/src/configuration.dart';
import 'package:force_directed_graphview/src/util/extensions.dart';
import 'package:force_directed_graphview/src/widget/graph_layout_view.dart';
import 'package:force_directed_graphview/src/widget/inherited_configuration.dart';
import 'package:vector_math/vector_math_64.dart';

part 'controller.dart';

/// A builder that should be used to wrap a [child] with something.
typedef ChildBuilder = Widget Function(
  BuildContext context,
  Widget child,
);

/// A widget that displays a graph.
class GraphView<N extends NodeBase, E extends EdgeBase<N>>
    extends StatefulWidget {
  /// {@nodoc}
  const GraphView({
    required this.nodeBuilder,
    required this.controller,
    required this.canvasSize,
    required this.layoutAlgorithm,
    this.lazyBuilding = const LazyBuilding.none(),
    this.edgePainter = const LineEdgePainter(),
    this.labelBuilder,
    this.canvasBackgroundBuilder,
    this.loaderBuilder,
    this.builder,
    this.minScale = 0.5,
    this.maxScale = 2,
    super.key,
  });

  /// The builder that builds the visual representation of the node.
  final NodeViewBuilder<N> nodeBuilder;

  /// The painter that paints the edge.
  final EdgePainter<N, E> edgePainter;

  /// The builder that builds the label of the node.
  final LabelBuilder<N>? labelBuilder;

  /// The builder that builds the background of the graph.
  /// If null, the background will be transparent.
  final WidgetBuilder? canvasBackgroundBuilder;

  /// The builder that builds the loading widget before the first
  /// layout is applied. If null, displays [SizedBox.shrink()]
  final WidgetBuilder? loaderBuilder;

  /// The controller that controls the graph.
  final GraphController<N, E> controller;

  /// The layout algorithm that is used to layout the graph.
  final GraphLayoutAlgorithm layoutAlgorithm;

  /// The size of the graph canvas. May exceed the size of the screen.
  final GraphCanvasSize canvasSize;

  /// The strategy that is used to lazily render the graph.
  final LazyBuilding lazyBuilding;

  /// Allows to add additional widgets right above the canvas,
  /// but below the [InteractiveViewer]. Similar to [MaterialApp.builder].
  final ChildBuilder? builder;

  /// The minimum scale of the [InteractiveViewer] that wraps the graph.
  final double minScale;

  /// The maximum scale of the [InteractiveViewer] that wraps the graph.
  final double maxScale;

  @override
  State<GraphView<N, E>> createState() => _GraphViewState<N, E>();
}

class _GraphViewState<N extends NodeBase, E extends EdgeBase<N>>
    extends State<GraphView<N, E>> {
  final _transformationController = TransformationController();
  var _isLayoutApplied = false;

  @override
  void didUpdateWidget(covariant GraphView<N, E> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.layoutAlgorithm != widget.layoutAlgorithm ||
        oldWidget.canvasSize != widget.canvasSize ||
        oldWidget.lazyBuilding != widget.lazyBuilding) {
      _initController(
        shouldLayout: oldWidget.layoutAlgorithm != widget.layoutAlgorithm,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _initController(shouldLayout: true);
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _initController({
    required bool shouldLayout,
  }) {
    widget.controller._applyConfiguration(
      algorithm: widget.layoutAlgorithm,
      size: widget.canvasSize,
      lazyBuilding: widget.lazyBuilding,
      transformationController: _transformationController,
      shouldLayout: shouldLayout,
    );
  }

  void _onControllerChanged() {
    final hasLayout = widget.controller.canLayout;
    if (hasLayout != _isLayoutApplied) {
      setState(() => _isLayoutApplied = hasLayout);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLayoutApplied) {
      return widget.loaderBuilder?.call(context) ?? const SizedBox.shrink();
    }

    return InheritedConfiguration(
      controller: widget.controller,
      configuration: GraphViewConfiguration(
        nodeBuilder: DefaultNodeBuilder<N>(builder: widget.nodeBuilder),
        edgePainter: widget.edgePainter,
        labelBuilder: widget.labelBuilder,
        layoutAlgorithm: widget.layoutAlgorithm,
        canvasBackgroundBuilder: widget.canvasBackgroundBuilder,
        builder: widget.builder,
      ),
      child: InteractiveViewer.builder(
        transformationController: _transformationController,
        maxScale: widget.maxScale,
        minScale: widget.minScale,
        builder: (context, viewport) {
          // Build method is not intended to produce any side effects,
          // but viewport-producing code is internal to InteractiveViewer,
          // so to avoid duplicating it, this little workaround is used.
          widget.controller._updateViewport(viewport);
          return const GraphLayoutView();
        },
      ),
    );
  }
}
