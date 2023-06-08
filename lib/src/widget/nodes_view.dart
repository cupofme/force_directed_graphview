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

        return CustomMultiChildLayout(
          delegate: _NodesLayoutDelegate(controller: controller),
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
    required this.controller,
  }) : super(relayout: controller);

  final GraphController controller;

  @override
  void performLayout(Size size) {
    final layout = controller.layout;
    final visibleNodes = controller.getVisibleNodes();

    for (final node in visibleNodes) {
      final sizeSquare = Size.square(node.size);
      layoutChild(node, BoxConstraints.loose(sizeSquare));
      positionChild(
        node,
        layout.getPosition(node) - sizeSquare.center(Offset.zero),
      );
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) => false;
}
