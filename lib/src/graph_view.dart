import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:force_directed_graphview/force_directed_graphview.dart';
import 'package:force_directed_graphview/src/widget/graph_layout_view.dart';
import 'package:force_directed_graphview/src/widget/inherited_configuration.dart';

import 'configuration.dart';

class GraphView extends StatefulWidget {
  const GraphView({
    required this.nodeBuilder,
    required this.edgePainter,
    required this.controller,
    required this.size,
    required this.layoutAlgorithm,
    this.labelBuilder,
    this.backgroundBuilder,
    this.minScale = 0.5,
    this.maxScale = 2,
    required this.labelTextStyle,
    super.key,
  });

  final NodeBuilder nodeBuilder;
  final EdgePainter edgePainter;
  final LabelBuilder? labelBuilder;
  final GraphController controller;
  final GraphLayoutAlgorithm layoutAlgorithm;
  final Size size;
  final WidgetBuilder? backgroundBuilder;
  final double minScale;
  final double maxScale;

  final TextStyle labelTextStyle;

  @override
  State<GraphView> createState() => _GraphViewState();
}

class _GraphViewState extends State<GraphView> {
  @override
  void didUpdateWidget(covariant GraphView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.layoutAlgorithm != widget.layoutAlgorithm ||
        oldWidget.size != widget.size) {
      widget.controller.applyLayout(widget.layoutAlgorithm, widget.size);
    }
  }

  @override
  void initState() {
    super.initState();
    widget.controller.applyLayout(widget.layoutAlgorithm, widget.size);
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
        labelStyle: widget.labelTextStyle,
        backgroundBuilder: widget.backgroundBuilder,
      ),
      child: InteractiveViewer.builder(
        maxScale: widget.maxScale,
        minScale: widget.minScale,
        builder: (context, viewport) {
          widget.controller.updateViewport(viewport);
          return const GraphLayoutView();
        },
      ),
    );
  }
}
