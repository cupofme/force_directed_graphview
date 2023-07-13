import 'dart:math';

import 'package:example/src/model/user.dart';
import 'package:example/src/widget/background_grid.dart';
import 'package:example/src/widget/user_node.dart';
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
            mutator.addEdge(Edge(node, other));
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
      floatingActionButton: _ZoomButtons(controller: _controller),
      body: Stack(
        children: [
          GraphView(
            controller: _controller,
            size: const Size.square(3000),
            layoutAlgorithm: const FruchtermanReingoldAlgorithm(
              iterations: 500,
            ),
            nodeBuilder: (context, node) => UserNode(
              node: node,
              onPressed: () {
                final newNode = Node(
                  data: User.generate(),
                  size: node.size,
                );

                _controller.mutate((mutator) {
                  mutator.addNode(newNode);
                  mutator.addEdge(Edge(node, newNode));
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
    return const Positioned(
      bottom: 16,
      left: 16,
      child: DefaultTextStyle(
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tap to add a node'),
            Text('Long press to delete a node'),
            Text('Double tap to focus on node')
          ],
        ),
      ),
    );
  }
}

class _ZoomButtons extends StatelessWidget {
  const _ZoomButtons({
    required this.controller,
  });

  final GraphController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: () => controller.zoomIn(),
          heroTag: 'zoomIn',
          child: const Icon(Icons.zoom_in),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          onPressed: () => controller.zoomOut(),
          heroTag: 'zoomOut',
          child: const Icon(Icons.zoom_out),
        ),
      ],
    );
  }
}
