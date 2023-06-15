import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:force_directed_graphview/src/algorithm/fruchterman_reingold_algorithm.dart';
import 'package:force_directed_graphview/src/model/edge.dart';
import 'package:force_directed_graphview/src/model/graph_layout.dart';
import 'package:force_directed_graphview/src/model/node.dart';

/// An interface for graph layout algorithm
///
/// See [FruchtermanReingoldAlgorithm] as built-in implementation
@immutable
abstract class GraphLayoutAlgorithm {
  /// Method that runs the first layout.
  /// Could be used to show updates as the layout is running.
  /// If iterations are not needed, then this method should yield a single
  /// layout in the end.
  Stream<GraphLayout> layout({
    required Set<Node> nodes,
    required Set<Edge> edges,
    required Size size,
  });

  /// Method that runs the layout again after graph changes.
  /// Can use the existing layout as a starting point.
  Stream<GraphLayout> relayout({
    required GraphLayout existingLayout,
    required Set<Node> nodes,
    required Set<Edge> edges,
    required Size size,
  });
}
