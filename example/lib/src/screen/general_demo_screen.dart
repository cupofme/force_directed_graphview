import 'dart:math';

import 'package:context_menus/context_menus.dart';
import 'package:example/src/model/user.dart';
import 'package:example/src/widget/background_grid.dart';
import 'package:example/src/widget/control_buttons.dart';
import 'package:example/src/widget/user_node.dart';
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
  final _controller = GraphController<Node<User>, Edge<Node<User>, int>>();

  Set<Node<User>> get _nodes => _controller.nodes;

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
          pinned: _random.nextInt(nodeCount ~/ 3) == 0,
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('General Graph Demo'),
      ),
      floatingActionButton: ControlButtons(controller: _controller),
      body: Stack(
        children: [
          GraphView<Node<User>, Edge<Node<User>, int>>(
            controller: _controller,
            canvasSize: const GraphCanvasSize.proportional(20),
            edgePainter: const _CustomEdgePainter(),
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
            nodeBuilder: (context, node) => _NodeView(
              controller: _controller,
              node: node,
            ),
            labelBuilder: BottomLabelBuilder(
              builder: (context, node) {
                final user = node.data;

                return Text(
                  '${user.firstName} ${user.lastName}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: node.size / 5,
                  ),
                );
              },
              labelSize: const Size.square(100),
            ),
            canvasBackgroundBuilder: (context) => const BackgroundGrid(),
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

class _NodeView extends StatelessWidget {
  const _NodeView({
    required this.controller,
    required this.node,
  });

  final GraphController<Node<User>, Edge<Node<User>, int>> controller;
  final Node<User> node;

  @override
  Widget build(BuildContext context) {
    return ContextMenuRegion(
      contextMenu: GenericContextMenu(
        buttonConfigs: [
          ContextMenuButtonConfig(
            'Add node',
            icon: const Icon(Icons.add),
            onPressed: () {
              final newNode = Node(
                data: User.generate(),
                size: node.size,
              );

              final newEdge = Edge(
                source: node,
                destination: newNode,
                data: 4,
              );

              controller.mutate((mutator) {
                mutator
                  ..addNode(newNode)
                  ..addEdge(newEdge);
              });
            },
          ),
          ContextMenuButtonConfig(
            'Pin/Unpin',
            icon: const Icon(Icons.pin_drop_outlined),
            onPressed: () {
              controller.setPinned(node, !node.pinned);
            },
          ),
          ContextMenuButtonConfig(
            'Replace node',
            icon: const Icon(Icons.replay_outlined),
            onPressed: () => controller.replaceNode(
              node,
              Node(
                data: User.generate(),
                size: node.size * 1.2,
              ),
            ),
          ),
          ContextMenuButtonConfig(
            'Jump To',
            icon: const Icon(Icons.circle_outlined),
            onPressed: () => controller.jumpToNode(node),
          ),
          ContextMenuButtonConfig(
            'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              controller.mutate(
                (mutator) => mutator.removeNode(node),
              );
            },
          ),
        ],
      ),
      child: UserNode(node: node),
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
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        child: Container(
          padding: const EdgeInsets.all(8),
          color: Colors.white,
          child: const Text('Long press on node\nto open context menu'),
        ),
      ),
    );
  }
}

class _CustomEdgePainter
    implements EdgePainter<Node<User>, Edge<Node<User>, int>> {
  const _CustomEdgePainter();

  @override
  void paint(
    Canvas canvas,
    Edge<Node<User>, int> edge,
    Offset sourcePosition,
    Offset destinationPosition,
  ) {
    canvas.drawLine(
      sourcePosition,
      destinationPosition,
      Paint()
        ..color = Colors.black.withAlpha(edge.data)
        ..strokeWidth = 2,
    );
  }
}
