import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:force_directed_graphview/force_directed_graphview.dart';
import 'package:force_directed_graphview/src/util/extensions.dart';
import 'package:force_directed_graphview/src/widget/graph_layout_view.dart';
import 'package:force_directed_graphview/src/widget/inherited_configuration.dart';
import 'package:vector_math/vector_math_64.dart';

import 'configuration.dart';

part 'controller.dart';

class GraphView extends StatefulWidget {
  const GraphView({
    required this.nodeBuilder,
    required this.edgePainter,
    required this.controller,
    required this.size,
    required this.layoutAlgorithm,
    this.labelBuilder,
    this.backgroundBuilder,
    this.loadingBuilder,
    this.minScale = 0.5,
    this.maxScale = 2,
    super.key,
  });

  final NodeBuilder nodeBuilder;
  final EdgePainter edgePainter;
  final LabelBuilder? labelBuilder;
  final WidgetBuilder? backgroundBuilder;
  final WidgetBuilder? loadingBuilder;

  final GraphController controller;
  final GraphLayoutAlgorithm layoutAlgorithm;
  final Size size;

  final double minScale;
  final double maxScale;

  @override
  State<GraphView> createState() => _GraphViewState();
}

class _GraphViewState extends State<GraphView> {
  final _transformationController = TransformationController();

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
  }

  @override
  Widget build(BuildContext context) {
    return InheritedConfiguration(
      controller: widget.controller,
      configuration: GraphViewConfiguration(
        nodeBuilder: widget.nodeBuilder,
        edgePainter: widget.edgePainter,
        labelBuilder: widget.labelBuilder,
        layoutAlgorithm: widget.layoutAlgorithm,
        size: widget.size,
        backgroundBuilder: widget.backgroundBuilder,
        loadingBuilder: widget.loadingBuilder,
      ),
      child: InteractiveViewer.builder(
        transformationController: _transformationController,
        maxScale: widget.maxScale,
        minScale: widget.minScale,
        builder: (context, viewport) {
          // Build method is not intended to produce any side effects, but viewport-producing
          // code is internal to InteractiveViewer, so to avoid duplicating it, this little hack is used.
          widget.controller._updateViewport(viewport);
          return const GraphLayoutView();
        },
      ),
    );
  }
}
