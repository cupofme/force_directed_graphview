import 'package:flutter/widgets.dart';
import 'package:force_directed_graphview/src/label_builder/label_builder.dart';
import 'package:force_directed_graphview/src/model/node.dart';

final class BottomLabelBuilder<N extends NodeBase> implements LabelBuilder<N> {
  BottomLabelBuilder({
    required this.labelExtractor,
    required this.labelSize,
  });

  final Widget Function(BuildContext context, N node) labelExtractor;
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

    layoutChild(BoxConstraints.loose(labelSize));

    positionChild(
      nodePosition +
          Offset(-node.size / 2, node.size / 2) +
          Offset(widthDelta / 2, 0),
    );
  }

  @override
  Widget build(BuildContext context, N node) {
    return labelExtractor(context, node);
  }
}
