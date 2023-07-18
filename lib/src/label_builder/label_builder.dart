import 'package:flutter/widgets.dart';
import 'package:force_directed_graphview/src/model/node.dart';

abstract interface class LabelBuilder<N extends NodeBase> {
  void performLayout(
    Size size,
    N node,
    Offset nodePosition,
    Size Function(BoxConstraints constraints) layoutChild,
    void Function(Offset offset) positionChild,
  );

  Widget build(BuildContext context, N node);
}
