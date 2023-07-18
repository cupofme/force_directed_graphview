import 'package:flutter/material.dart';
import 'package:force_directed_graphview/src/widget/edges_view.dart';
import 'package:force_directed_graphview/src/widget/inherited_configuration.dart';
import 'package:force_directed_graphview/src/widget/labels_view.dart';
import 'package:force_directed_graphview/src/widget/nodes_view.dart';

/// {@nodoc}
class GraphLayoutView extends StatelessWidget {
  /// {@nodoc}
  const GraphLayoutView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final configuration = InheritedConfiguration.configurationOf(context);
    final controller = InheritedConfiguration.controllerOf(context);
    final backgroundBuilder = configuration.canvasBackgroundBuilder;
    final builder = configuration.builder;

    Widget result = SizedBox.fromSize(
      size: controller.canvasSize,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (backgroundBuilder != null)
            RepaintBoundary(
              child: backgroundBuilder(context),
            ),
          const EdgesView(),
          const LabelsView(),
          const NodesView(),
        ],
      ),
    );

    if (builder != null) {
      result = builder(context, result);
    }

    return result;
  }
}
