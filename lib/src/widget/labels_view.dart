import 'package:flutter/material.dart';
import 'package:force_directed_graphview/force_directed_graphview.dart';
import 'package:force_directed_graphview/src/configuration.dart';
import 'package:force_directed_graphview/src/widget/inherited_configuration.dart';

class LabelsView extends StatelessWidget {
  const LabelsView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = InheritedConfiguration.controllerOf(context);
    final configuration = InheritedConfiguration.configurationOf(context);

    return RepaintBoundary(
      child: CustomPaint(
        painter: _LabelsPainter(
          controller: controller,
          configuration: configuration,
        ),
      ),
    );
  }
}

class _LabelsPainter extends CustomPainter {
  _LabelsPainter({
    required this.controller,
    required this.configuration,
  }) : super(repaint: controller);

  final GraphController controller;
  final GraphViewConfiguration configuration;

  @override
  void paint(Canvas canvas, Size size) {
    final nodes = controller.getVisibleNodes();
    final layout = controller.layout;

    for (final node in nodes) {
      final label = node.label;

      if (label != null) {
        // todo configure size
        final textPainter = TextPainter(
            text: TextSpan(text: label, style: configuration.labelStyle),
            textAlign: TextAlign.justify,
            textDirection: TextDirection.ltr)
          ..layout(minWidth: 0, maxWidth: 200);

        textPainter.paint(
          canvas,
          layout.getPosition(node) +
              Offset(-textPainter.width / 2, node.size / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
