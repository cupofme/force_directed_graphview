import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:force_directed_graphview/src/model/edge.dart';
import 'package:force_directed_graphview/src/model/graph_layout.dart';
import 'package:force_directed_graphview/src/model/node.dart';

@immutable
abstract class GraphLayoutAlgorithm {
  Stream<GraphLayout> layout({
    required Set<Node> nodes,
    required Set<Edge> edges,
    required Size size,
  });

  Stream<GraphLayout> relayout({
    required GraphLayout existingLayout,
    required Set<Node> nodes,
    required Set<Edge> edges,
    required Size size,
  });
}
