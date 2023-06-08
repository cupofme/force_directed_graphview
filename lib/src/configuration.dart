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
    required this.labelStyle,
    required this.backgroundBuilder,
  });

  final NodeBuilder nodeBuilder;
  final EdgePainter edgePainter;
  final LabelBuilder? labelBuilder;
  final WidgetBuilder? backgroundBuilder;

  final GraphLayoutAlgorithm layoutAlgorithm;
  final Size size;
  final TextStyle labelStyle;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GraphViewConfiguration &&
          runtimeType == other.runtimeType &&
          nodeBuilder == other.nodeBuilder &&
          edgePainter == other.edgePainter &&
          backgroundBuilder == other.backgroundBuilder &&
          layoutAlgorithm == other.layoutAlgorithm &&
          size == other.size;

  @override
  int get hashCode =>
      nodeBuilder.hashCode ^
      edgePainter.hashCode ^
      backgroundBuilder.hashCode ^
      layoutAlgorithm.hashCode ^
      size.hashCode;
}
