import 'package:flutter/material.dart';
import 'package:force_directed_graphview/force_directed_graphview.dart';
import 'package:force_directed_graphview/src/widget/inherited_configuration.dart';

class LabelsView extends StatelessWidget {
  const LabelsView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = InheritedConfiguration.controllerOf(context);
    final configuration = InheritedConfiguration.configurationOf(context);
    final labelBuilder = configuration.labelBuilder;

    if (labelBuilder == null) {
      return const SizedBox();
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final visibleNodes = controller.getVisibleNodes();
        final layout = controller.layout;
        final labeledNodes = visibleNodes.where((node) => node.label != null);

        return CustomMultiChildLayout(
          delegate: _LabelsLayoutDelegate(
            nodes: visibleNodes,
            layout: layout,
          ),
          children: [
            for (var node in labeledNodes)
              LayoutId(
                id: node,
                child: RepaintBoundary(
                  child: configuration.labelBuilder!(context, node),
                ),
              )
          ],
        );
      },
    );
  }
}

class _LabelsLayoutDelegate extends MultiChildLayoutDelegate {
  _LabelsLayoutDelegate({
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
        layout.getPosition(node) +
            Offset(
              -node.size / 2,
              node.size / 2,
            ),
      );
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) => true;
}
