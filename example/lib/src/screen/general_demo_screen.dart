import 'dart:math';

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
            canvasSize: const GraphCanvasSize.proportional(50),
            edgePainter: const _CustomEdgePainter(),
            layoutAlgorithm: FruchtermanReingoldAlgorithm(
              iterations: 500,
              showIterations: true,
              maxDistance: 300,
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
            nodeBuilder: (context, node) => _ContextMenuNode(
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

enum _ContextMenuAction {
  addNode,
  pinUnpin,
  replace,
  jumpTo,
  delete,
}

class _ContextMenuNode extends StatelessWidget {
  const _ContextMenuNode({
    required this.controller,
    required this.node,
  });

  final GraphController<Node<User>, Edge<Node<User>, int>> controller;
  final Node<User> node;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      onSelected: _performAction,
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _ContextMenuAction.addNode,
          child: Text('Add node'),
        ),
        PopupMenuItem(
          value: _ContextMenuAction.pinUnpin,
          child: Text('Pin/Unpin'),
        ),
        PopupMenuItem(
          value: _ContextMenuAction.replace,
          child: Text('Replace node'),
        ),
        PopupMenuItem(
          value: _ContextMenuAction.jumpTo,
          child: Text('Jump To'),
        ),
        PopupMenuItem(
          value: _ContextMenuAction.delete,
          child: Text('Delete'),
        ),
      ],
      child: UserNode(node: node),
    );
  }

  void _performAction(_ContextMenuAction value) {
    switch (value) {
      case _ContextMenuAction.addNode:
        final newNode = Node(
          data: User.generate(),
          size: node.size,
        );

        final newEdge = Edge(
          source: node,
          destination: newNode,
          data: 100,
        );

        controller.mutate((mutator) {
          mutator
            ..addNode(newNode)
            ..addEdge(newEdge);
        });

      case _ContextMenuAction.pinUnpin:
        controller.setPinned(node, !node.pinned);
      case _ContextMenuAction.replace:
        controller.replaceNode(
          node,
          Node(
            data: User.generate(),
            size: node.size * 1.2,
          ),
        );
      case _ContextMenuAction.jumpTo:
        controller.jumpToNode(node);
      case _ContextMenuAction.delete:
        controller.mutate(
          (mutator) => mutator.removeNode(node),
        );
    }
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
          child: const Text('Tap node to open context menu'),
        ),
      ),
    );
  }
}
