import 'dart:math';

import 'package:example/src/model/user.dart';
import 'package:example/src/widget/background_grid.dart';
import 'package:example/src/widget/user_node.dart';
import 'package:flutter/material.dart';
import 'package:force_directed_graphview/force_directed_graphview.dart';

class LargeDemoScreen extends StatefulWidget {
  const LargeDemoScreen({
    super.key,
  });

  @override
  LargeDemoScreenState createState() => LargeDemoScreenState();
}

class LargeDemoScreenState extends State<LargeDemoScreen> {
  late final _controller = GraphController();

  final _random = Random(0);

  static const _nodeCount = 3000;
  static const _nodeSize = 50.0;

  @override
  void initState() {
    super.initState();

    _controller.mutate((mutator) {
      for (var i = 0; i < _nodeCount; i++) {
        final node = Node(
          data: User.generate(),
          size: _nodeSize,
        );

        mutator.addNode(node);
      }

      final nodes = _controller.nodes.toList();

      for (final node in nodes.take(_nodeCount ~/ 10)) {
        final other = nodes.elementAt(_random.nextInt(_nodeCount));

        if (other != node) {
          mutator.addEdge(Edge(node, other));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Large Graph Demo ($_nodeCount nodes)'),
      ),
      body: GraphView(
        controller: _controller,
        size: const Size.square(7000),
        minScale: 0.1,
        maxScale: 10,
        layoutAlgorithm: const GridLayoutAlgorithm(),
        nodeBuilder: (context, node) => UserNode(node: node),
        edgePainter: (canvas, edge, sourcePosition, targetPosition) {
          canvas.drawLine(
            sourcePosition,
            targetPosition,
            Paint()..color = Colors.black54,
          );
        },
        backgroundBuilder: (context) => const BackgroundGrid(),
      ),
    );
  }
}

class GridLayoutAlgorithm implements GraphLayoutAlgorithm {
  const GridLayoutAlgorithm();

  @override
  Stream<GraphLayout> layout({
    required Set<Node> nodes,
    required Set<Edge> edges,
    required Size size,
  }) async* {
    final layoutBuilder = GraphLayoutBuilder(
      nodes: nodes,
      edges: edges,
    );

    final nodeCount = nodes.length;
    final nodeSize = size.width / sqrt(nodeCount);

    var x = 0.0;
    var y = 0.0;

    for (final node in nodes) {
      layoutBuilder.setNodePosition(
        node,
        Offset(x, y),
      );

      x += nodeSize;

      if (x >= size.width) {
        x = 0;
        y += nodeSize;
      }
    }

    yield layoutBuilder.build();
  }

  @override
  Stream<GraphLayout> relayout({
    required GraphLayout existingLayout,
    required Set<Node> nodes,
    required Set<Edge> edges,
    required Size size,
  }) async* {
    yield* layout(
      nodes: nodes,
      edges: edges,
      size: size,
    );
  }
}
