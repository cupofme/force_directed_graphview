import 'package:flutter/widgets.dart';
import 'package:force_directed_graphview/src/model/node.dart';

abstract interface class NodeBuilder<N extends NodeBase> {
  Widget build(BuildContext context, N node);
}
