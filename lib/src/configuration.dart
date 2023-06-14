import 'package:flutter/widgets.dart';
import 'package:force_directed_graphview/force_directed_graphview.dart';

typedef NodeBuilder = Widget Function(BuildContext context, Node node);
typedef EdgePainter = void Function(
  Canvas canvas,
  Edge edge,
  Offset sourcePosition,
  Offset targetPosition,
);

typedef LabelBuilder = Widget Function(BuildContext context, Node node);

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
