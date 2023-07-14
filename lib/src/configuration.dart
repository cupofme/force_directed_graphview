import 'package:flutter/widgets.dart';
import 'package:force_directed_graphview/force_directed_graphview.dart';

/// Configuration for the graph view.
/// Used as a convenient way to pass multiple parameters
/// to the internal widgets.
@immutable
class GraphViewConfiguration {
  /// {@nodoc}
  const GraphViewConfiguration({
    required this.nodeBuilder,
    required this.edgePainter,
    required this.labelBuilder,
    required this.layoutAlgorithm,
    required this.backgroundBuilder,
  });

  /// {@nodoc}
  final NodeBuilder nodeBuilder;

  /// {@nodoc}
  final EdgePainter edgePainter;

  /// {@nodoc}
  final LabelBuilder? labelBuilder;

  /// {@nodoc}
  final WidgetBuilder? backgroundBuilder;

  /// {@nodoc}
  final GraphLayoutAlgorithm layoutAlgorithm;
}
