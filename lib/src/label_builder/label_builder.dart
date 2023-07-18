import 'package:flutter/widgets.dart';
import 'package:force_directed_graphview/src/model/node.dart';

/// Interbase class for label builders.
abstract interface class LabelBuilder<N extends NodeBase> {
  /// Performs the layout of the label.
  /// API is similar to [CustomMultiChildLayout].
  void performLayout(
    Size size,
    N node,
    Offset nodePosition,
    Size Function(BoxConstraints constraints) layoutChild,
    void Function(Offset offset) positionChild,
  );

  /// Creates the label widget for the node.
  Widget build(BuildContext context, N node);
}
