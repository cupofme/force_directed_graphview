import 'package:flutter/widgets.dart';
import 'package:force_directed_graphview/src/label_builder/label_builder.dart';
import 'package:force_directed_graphview/src/model/node.dart';

/// Label builder that places the label below the node.
final class BottomLabelBuilder<N extends NodeBase> implements LabelBuilder<N> {
  /// { @nodoc }
  BottomLabelBuilder({
    required this.builder,
    required this.labelSize,
  });

  /// Extracts the label widget from the node.
  final Widget Function(BuildContext context, N node) builder;

  /// The size of the area available to the label.
  final Size labelSize;

  @override
  void performLayout(
    Size size,
    N node,
    Offset nodePosition,
    Size Function(BoxConstraints constraints) layoutChild,
    void Function(Offset offset) positionChild,
  ) {
    final widthDelta = node.size - labelSize.width;

    layoutChild(BoxConstraints.tight(labelSize));

    positionChild(
      nodePosition +
          Offset(-node.size / 2, node.size / 2) +
          Offset(widthDelta / 2, 0),
    );
  }

  @override
  Widget build(BuildContext context, N node) {
    return builder(context, node);
  }
}
