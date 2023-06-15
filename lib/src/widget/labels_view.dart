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

        final nodeToLabel = {
          for (var node in visibleNodes) node: labelBuilder(context, node),
        }..removeWhere((key, value) => value == null);

        return CustomMultiChildLayout(
          delegate: _LabelsLayoutDelegate(
            nodesMap: nodeToLabel.cast(),
            layout: layout,
          ),
          children: [
            for (var entry in nodeToLabel.entries)
              LayoutId(
                id: entry.key,
                child: RepaintBoundary(
                  child: entry.value!.child,
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
    required this.nodesMap,
    required this.layout,
  });

  final Map<Node, LabelConfiguration> nodesMap;
  final GraphLayout layout;

  @override
  void performLayout(Size size) {
    for (final entry in nodesMap.entries) {
      final node = entry.key;
      final widthDiff = node.size - entry.value.size.width;

      layoutChild(node, BoxConstraints.loose(entry.value.size));

      positionChild(
        node,
        layout.getPosition(node) +
            Offset(-node.size / 2, node.size / 2) +
            Offset(widthDiff / 2, 0),
      );
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) => true;
}
