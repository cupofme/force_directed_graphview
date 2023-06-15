import 'package:flutter/widgets.dart';
import 'package:force_directed_graphview/src/model/edge.dart';
import 'package:force_directed_graphview/src/model/label_configuration.dart';
import 'package:force_directed_graphview/src/model/node.dart';

/// Callback for building a widget for a node
typedef NodeBuilder = Widget Function(
  BuildContext context,
  Node node,
);

/// Callback for painting an edge using a [Canvas] API.
/// Provided positions are the centers of the two connected nodes.
typedef EdgePainter = void Function(
  Canvas canvas,
  Edge edge,
  Offset sourcePosition,
  Offset targetPosition,
);

/// Callback for building a widget for a label,
/// returns a nullable [LabelConfiguration], if null is returned,
/// the label will not be shown.
typedef LabelBuilder = LabelConfiguration? Function(
  BuildContext context,
  Node node,
);
