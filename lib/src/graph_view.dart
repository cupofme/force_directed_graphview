import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:force_directed_graphview/force_directed_graphview.dart';
import 'package:force_directed_graphview/src/configuration.dart';
import 'package:force_directed_graphview/src/util/extensions.dart';
import 'package:force_directed_graphview/src/widget/graph_layout_view.dart';
import 'package:force_directed_graphview/src/widget/inherited_configuration.dart';
import 'package:vector_math/vector_math_64.dart';

part 'controller.dart';

/// A widget that displays a graph.
class GraphView extends StatefulWidget {
  const GraphView({
    required this.nodeBuilder,
    required this.edgePainter,
    required this.controller,
    required this.size,
    required this.layoutAlgorithm,
    this.labelBuilder,
    this.backgroundBuilder,
    this.loaderBuilder,
    this.minScale = 0.5,
    this.maxScale = 2,
    super.key,
  });

  /// The builder that builds the visual representation of the node.
  final NodeBuilder nodeBuilder;

  /// The painter that paints the edge.
  final EdgePainter edgePainter;

  /// The builder that builds the label of the node.
  final LabelBuilder? labelBuilder;

  /// The builder that builds the background of the graph.
  /// If null, the background will be transparent.
  final WidgetBuilder? backgroundBuilder;

  /// The builder that builds the loading widget before the first
  /// layout is applied. If null, displays [SizedBox.shrink()]
  final WidgetBuilder? loaderBuilder;

  /// The controller that controls the graph.
  final GraphController controller;

  /// The layout algorithm that is used to layout the graph.
  final GraphLayoutAlgorithm layoutAlgorithm;

  /// The size of the graph. May exceed the size of the screen.
  final Size size;

  /// The minimum scale of the [InteractiveViewer] that wraps the graph.
  final double minScale;

  /// The maximum scale of the [InteractiveViewer] that wraps the graph.
  final double maxScale;

  @override
  State<GraphView> createState() => _GraphViewState();
}

class _GraphViewState extends State<GraphView> {
  final _transformationController = TransformationController();
  var _isLayoutApplied = false;

  @override
  void didUpdateWidget(covariant GraphView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.layoutAlgorithm != widget.layoutAlgorithm ||
        oldWidget.size != widget.size) {
      widget.controller._applyLayout(widget.layoutAlgorithm, widget.size);
    }
  }

  @override
  void initState() {
    super.initState();
    widget.controller._applyLayout(widget.layoutAlgorithm, widget.size);
    widget.controller._setTransformationController(_transformationController);
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    final hasLayout = widget.controller.hasLayout;
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
        nodeBuilder: widget.nodeBuilder,
        edgePainter: widget.edgePainter,
        labelBuilder: widget.labelBuilder,
        layoutAlgorithm: widget.layoutAlgorithm,
        size: widget.size,
        backgroundBuilder: widget.backgroundBuilder,
      ),
      child: InteractiveViewer.builder(
        transformationController: _transformationController,
        maxScale: widget.maxScale,
        minScale: widget.minScale,
        builder: (context, viewport) {
          // Build method is not intended to produce any side effects,
          // but viewport-producing code is internal to InteractiveViewer,
          // so to avoid duplicating it, this little hack is used.
          widget.controller._updateViewport(viewport);
          return const GraphLayoutView();
        },
      ),
    );
  }
}
