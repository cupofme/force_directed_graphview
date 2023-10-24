import 'package:example/src/model/user.dart';
import 'package:flutter/material.dart';
import 'package:force_directed_graphview/force_directed_graphview.dart';

class ControlButtons extends StatelessWidget {
  const ControlButtons({
    required this.controller,
    super.key,
  });

  final GraphController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: () => controller.mutate((mutator) {
            mutator.addNode(
              Node(
                data: User.generate(),
                size: 100,
              ),
            );
          }),
          heroTag: 'add',
          child: const Icon(Icons.add_outlined),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          onPressed: () => controller.mutate((mutator) {
            mutator.clear();
          }),
          heroTag: 'clear',
          child: const Icon(Icons.clear),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          onPressed: controller.zoomIn,
          heroTag: 'zoomIn',
          child: const Icon(Icons.zoom_in),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          onPressed: controller.zoomOut,
          heroTag: 'zoomOut',
          child: const Icon(Icons.zoom_out),
        ),
      ],
    );
  }
}
