import 'package:flutter/widgets.dart';
import 'package:force_directed_graphview/src/model/node.dart';

/// Helper class that helps to overcome dart type system
/// limitations when working with functions.
/// Currently should not be used directly.
abstract interface class NodeBuilder<N extends NodeBase> {
  /// { @nodoc }
  Widget build(BuildContext context, N node);
}
