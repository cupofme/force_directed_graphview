import 'dart:math';

import 'package:example/src/model/user.dart';
import 'package:example/src/widgets/background_grid.dart';
import 'package:example/src/widgets/user_node.dart';
import 'package:flutter/material.dart';
import 'package:force_directed_graphview/force_directed_graphview.dart';

class GeneralDemoScreen extends StatefulWidget {
  const GeneralDemoScreen({
    super.key,
  });

  @override
  GeneralDemoScreenState createState() => GeneralDemoScreenState();
}

class GeneralDemoScreenState extends State<GeneralDemoScreen> {
  late final _controller = GraphController();

  Set<Node> get _nodes => _controller.nodes;

  final _random = Random(0);

  @override
  void initState() {
    super.initState();

    _controller.mutate((builder) {
      const nodeCount = 100;
      for (var i = 0; i < nodeCount; i++) {
        final size = i + 20;

        final user = User.generate();

        final node = Node(
          data: user,
          size: size.toDouble(),
          label: '${user.firstName} ${user.lastName}',
        );

        builder.addNode(node);

        for (final other in _nodes) {
          if (other != node && _random.nextInt(nodeCount + 40 - size) == 0) {
            builder.addEdge(Edge(node, other));
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('General Graph Demo'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GraphView(
              controller: _controller,
              size: const Size.square(3000),
              labelTextStyle: const TextStyle(color: Colors.black, fontSize: 20),
              layoutAlgorithm: const FruchtermanReingoldAlgorithm(iterations: 500),
              nodeBuilder: (context, node) => UserNode(
                node: node,
                onPressed: () {
                  final newNode = Node(
                    data: User.generate(),
                    size: node.size,
                    label: node.label,
                  );

                  _controller.mutate((builder) {
                    builder.addNode(newNode);
                    builder.addEdge(Edge(node, newNode));
                  });
                },
                onLongPressed: () => _controller.mutate((builder) => builder.removeNode(node)),
              ),
              edgePainter: (canvas, edge, sourcePosition, targetPosition) {
                canvas.drawLine(
                  sourcePosition,
                  targetPosition,
                  Paint()
                    ..strokeWidth = edge.source.size / edge.target.size
                    ..color = Colors.black54,
                );
              },
              backgroundBuilder: (context) => const BackgroundGrid(),
            ),
          ),
          const Text(
            'Tap to add a node, long press to delete the node',
            style: TextStyle(fontSize: 30),
          )
        ],
      ),
    );
  }
}
