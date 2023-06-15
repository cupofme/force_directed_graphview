import 'package:flutter/widgets.dart';
import 'package:force_directed_graphview/force_directed_graphview.dart';

/// Configuration for the graph view.
/// Used as a convenient way to pass multiple parameters
/// to the internal widgets.
@immutable
class GraphViewConfiguration {
  const GraphViewConfiguration({
    required this.nodeBuilder,
    required this.edgePainter,
    required this.labelBuilder,
    required this.layoutAlgorithm,
    required this.size,
    required this.backgroundBuilder,
    required this.loadingBuilder,
  });

  final NodeBuilder nodeBuilder;
  final EdgePainter edgePainter;
  final LabelBuilder? labelBuilder;
  final WidgetBuilder? backgroundBuilder;
  final WidgetBuilder? loadingBuilder;

  final GraphLayoutAlgorithm layoutAlgorithm;
  final Size size;
}
