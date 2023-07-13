import 'package:flutter/widgets.dart';
import 'package:force_directed_graphview/src/model/label_configuration.dart';
import 'package:force_directed_graphview/src/model/node.dart';

/// Callback for building a widget for a node
typedef NodeBuilder = Widget Function(
  BuildContext context,
  Node node,
);

/// Callback for building a widget for a label,
/// returns a nullable [LabelConfiguration], if null is returned,
/// the label will not be shown.
typedef LabelBuilder = LabelConfiguration? Function(
  BuildContext context,
  Node node,
);
