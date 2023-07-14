import 'dart:math';

import 'package:example/src/model/user.dart';
import 'package:example/src/widget/background_grid.dart';
import 'package:example/src/widget/user_node.dart';
import 'package:example/src/widget/zoom_buttons.dart';
import 'package:faker/faker.dart';
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
  final _controller = GraphController();

  Set<Node> get _nodes => _controller.nodes;

  final _random = Random(0);

  @override
  void initState() {
    super.initState();

    _controller.mutate((mutator) {
      const nodeCount = 100;
      for (var i = 0; i < nodeCount; i++) {
        final size = i + 20;

        final user = User.generate();

        final node = Node(
          data: user,
          size: size.toDouble(),
        );

        mutator.addNode(node);

        for (final other in _nodes) {
          if (other != node && _random.nextInt(nodeCount + 40 - size) == 0) {
            mutator.addEdge(
              Edge(
                node,
                other,
                data: Colors.black.withOpacity(random.decimal()),
              ),
            );
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
      floatingActionButton: ZoomButtons(controller: _controller),
      body: Stack(
        children: [
          GraphView(
            controller: _controller,
            canvasSize: const GraphCanvasSize.proportional(20),
            edgePainter: const _CustomEdgePainter(),
            layoutAlgorithm: const FruchtermanReingoldAlgorithm(
              iterations: 500,
              showIterations: true,
            ),
            nodeBuilder: (context, node) => UserNode(
              node: node,
              onPressed: () {
                final newNode = Node(
                  data: User.generate(),
                  size: node.size,
                );

                _controller.mutate((mutator) {
                  mutator
                    ..addNode(newNode)
                    ..addEdge(Edge(node, newNode));
                });
              },
              onLongPressed: () => _controller.mutate(
                (mutator) => mutator.removeNode(node),
              ),
              onDoubleTap: () => _controller.jumpToNode(node),
            ),
            labelBuilder: (context, node) {
              if (node.size < 50) {
                return null;
              }

              final user = node.data as User;

              return LabelConfiguration(
                size: Size.square(node.size * 2),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      '${user.firstName} ${user.lastName}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: node.size / 5,
                      ),
                    ),
                  ),
                ),
              );
            },
            backgroundBuilder: (context) => const BackgroundGrid(),
            loaderBuilder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          const _Instructions(),
        ],
      ),
    );
  }
}

class _Instructions extends StatelessWidget {
  const _Instructions();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 8,
      left: 8,
      child: DefaultTextStyle(
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        child: Container(
          padding: const EdgeInsets.all(8),
          color: Colors.white,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tap to add a node'),
              Text('Long press to delete a node'),
              Text('Double tap to focus on node')
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomEdgePainter implements EdgePainter {
  const _CustomEdgePainter();

  @override
  void paint(
    Canvas canvas,
    Edge edge,
    Offset sourcePosition,
    Offset destinationPosition,
  ) {
    canvas.drawLine(
      sourcePosition,
      destinationPosition,
      Paint()
        ..color = (edge.data as Color?) ?? Colors.black
        ..strokeWidth = 2,
    );
  }
}
