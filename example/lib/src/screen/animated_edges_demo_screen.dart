import 'dart:math';

import 'package:example/src/model/user.dart';
import 'package:example/src/widget/background_grid.dart';
import 'package:example/src/widget/control_buttons.dart';
import 'package:example/src/widget/user_node.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:force_directed_graphview/force_directed_graphview.dart';

class AnimatedEdgesDemoScreen extends StatefulWidget {
  const AnimatedEdgesDemoScreen({
    super.key,
  });

  @override
  AnimatedEdgesDemoScreenState createState() => AnimatedEdgesDemoScreenState();
}

class AnimatedEdgesDemoScreenState extends State<AnimatedEdgesDemoScreen>
    with SingleTickerProviderStateMixin {
  final _controller = GraphController<Node<User>, Edge<Node<User>, int>>();

  late final _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..repeat();

  Set<Node<User>> get _nodes => _controller.nodes;

  final _random = Random(0);

  @override
  void initState() {
    super.initState();

    _controller.mutate((mutator) {
      const nodeCount = 50;
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
                source: node,
                destination: other,
                data: random.integer(255, min: 100),
              ),
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animated Edges Demo'),
      ),
      floatingActionButton: ControlButtons(controller: _controller),
      body: Stack(
        children: [
          GraphView<Node<User>, Edge<Node<User>, int>>(
            controller: _controller,
            canvasSize: const GraphCanvasSize.proportional(50),
            edgePainter: AnimatedDashEdgePainter(
              thickness: 2,
              animation: _animationController,
            ),
            layoutAlgorithm: FruchtermanReingoldAlgorithm(
              iterations: 500,
              showIterations: true,
              initialPositionExtractor: (node, canvasSize) {
                if (node.pinned) {
                  return Offset(
                    _random.nextDouble() * canvasSize.width,
                    _random.nextDouble() * canvasSize.height,
                  );
                }

                return FruchtermanReingoldAlgorithm
                    .defaultInitialPositionExtractor(node, canvasSize);
              },
            ),
            nodeBuilder: (context, node) => UserNode(node: node),
            canvasBackgroundBuilder: (context) => const BackgroundGrid(),
          ),
        ],
      ),
    );
  }
}
