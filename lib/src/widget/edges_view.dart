import 'package:flutter/material.dart';
import 'package:force_directed_graphview/force_directed_graphview.dart';
import 'package:force_directed_graphview/src/configuration.dart';
import 'package:force_directed_graphview/src/widget/inherited_configuration.dart';

/// {@nodoc}
class EdgesView extends StatelessWidget {
  /// {@nodoc}
  const EdgesView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = InheritedConfiguration.controllerOf(context);
    final configuration = InheritedConfiguration.configurationOf(context);

    return RepaintBoundary(
      child: CustomPaint(
        painter: _EdgesPainter(
          controller: controller,
          configuration: configuration,
        ),
      ),
    );
  }
}

class _EdgesPainter extends CustomPainter {
  _EdgesPainter({
    required this.controller,
    required this.configuration,
  }) : super(repaint: controller);

  final GraphController controller;
  final GraphViewConfiguration configuration;

  @override
  void paint(Canvas canvas, Size size) {
    final layout = controller.layout;
    final edges = controller.edges;

    for (final edge in edges) {
      configuration.edgePainter.paint(
        canvas,
        edge,
        layout.getPosition(edge.source),
        layout.getPosition(edge.target),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
