import 'package:flutter/material.dart';
import 'package:force_directed_graphview/src/widget/edges_view.dart';
import 'package:force_directed_graphview/src/widget/inherited_configuration.dart';
import 'package:force_directed_graphview/src/widget/labels_view.dart';
import 'package:force_directed_graphview/src/widget/nodes_view.dart';

class GraphLayoutView extends StatelessWidget {
  const GraphLayoutView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final configuration = InheritedConfiguration.configurationOf(context);
    final controller = InheritedConfiguration.controllerOf(context);

    return SizedBox.fromSize(
      size: configuration.size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (configuration.backgroundBuilder != null)
            Positioned.fill(
              child: RepaintBoundary(
                child: configuration.backgroundBuilder!(context),
              ),
            ),
          AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              if (!controller.hasLayout) {
                return configuration.loadingBuilder?.call(context) ??
                    const SizedBox.shrink();
              }

              return child!;
            },
            child: const Stack(
              fit: StackFit.expand,
              children: [
                EdgesView(),
                LabelsView(),
                NodesView(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
