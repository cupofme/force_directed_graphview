import 'package:flutter/widgets.dart';
import 'package:force_directed_graphview/force_directed_graphview.dart';
import 'package:force_directed_graphview/src/widget/inherited_configuration.dart';

class NodesView extends StatelessWidget {
  const NodesView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = InheritedConfiguration.controllerOf(context);
    final configuration = InheritedConfiguration.configurationOf(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final visibleNodes = controller.getVisibleNodes();
        final layout = controller.layout;

        return CustomMultiChildLayout(
          delegate: _NodesLayoutDelegate(
            nodes: visibleNodes,
            layout: layout,
          ),
          children: [
            for (var node in visibleNodes)
              LayoutId(
                id: node,
                child: RepaintBoundary(
                  child: configuration.nodeBuilder(context, node),
                ),
              )
          ],
        );
      },
    );
  }
}

class _NodesLayoutDelegate extends MultiChildLayoutDelegate {
  _NodesLayoutDelegate({
    required this.nodes,
    required this.layout,
  });

  final Set<Node> nodes;
  final GraphLayout layout;

  @override
  void performLayout(Size size) {
    for (final node in nodes) {
      final sizeSquare = Size.square(node.size);
      layoutChild(node, BoxConstraints.loose(sizeSquare));
      positionChild(
        node,
        layout.getPosition(node) - sizeSquare.center(Offset.zero),
      );
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) => true;
}
