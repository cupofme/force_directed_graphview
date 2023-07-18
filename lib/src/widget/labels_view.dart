import 'package:flutter/material.dart';
import 'package:force_directed_graphview/force_directed_graphview.dart';
import 'package:force_directed_graphview/src/widget/inherited_configuration.dart';

/// {@nodoc}
class LabelsView extends StatelessWidget {
  /// {@nodoc}
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
          for (var node in visibleNodes)
            node: labelBuilder.build(context, node),
        };

        return CustomMultiChildLayout(
          delegate: _LabelsLayoutDelegate(
            labels: nodeToLabel,
            labelBuilder: labelBuilder,
            layout: layout,
          ),
          children: [
            for (var entry in nodeToLabel.entries)
              LayoutId(
                id: entry.key,
                child: RepaintBoundary(
                  child: entry.value,
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
    required this.labels,
    required this.labelBuilder,
    required this.layout,
  });

  final Map<NodeBase, Widget> labels;
  final GraphLayout layout;
  final LabelBuilder labelBuilder;

  @override
  void performLayout(Size size) {
    for (final entry in labels.entries) {
      final node = entry.key;

      labelBuilder.performLayout(
        size,
        node,
        layout.getPosition(node),
        (constraints) => layoutChild(node, constraints),
        (offset) => positionChild(node, offset),
      );
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) => true;
}
