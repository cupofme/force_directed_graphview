import 'dart:math';
import 'dart:ui';

import 'package:force_directed_graphview/force_directed_graphview.dart';

class FruchtermanReingoldAlgorithm implements GraphLayoutAlgorithm {
  const FruchtermanReingoldAlgorithm({
    this.iterations = 100,
    this.relayoutIterationsMultiplier = 0.1,
  });

  final int iterations;
  final double relayoutIterationsMultiplier;

  @override
  Stream<GraphLayout> layout({
    required Set<Node> nodes,
    required Set<Edge> edges,
    required Size size,
  }) {
    return _run(
      nodes: nodes,
      edges: edges,
      size: size,
      existingLayout: null,
    );
  }

  @override
  Stream<GraphLayout> relayout({
    required GraphLayout existingLayout,
    required Set<Node> nodes,
    required Set<Edge> edges,
    required Size size,
  }) {
    return _run(
      nodes: nodes,
      edges: edges,
      size: size,
      existingLayout: existingLayout,
    );
  }

  Stream<GraphLayout> _run({
    required Set<Node> nodes,
    required Set<Edge> edges,
    required Size size,
    required GraphLayout? existingLayout,
  }) async* {
    // todo - make this configurable
    var temp = sqrt(size.width / 2 * size.height / 2) / 20;
    final random = Random(0);

    final layoutBuilder = GraphLayoutBuilder(
      nodes: nodes,
      edges: edges,
    );

    for (final node in nodes) {
      layoutBuilder.setNodePosition(
        node,
        existingLayout?.getPositionOrNull(node) ??
            _randomPosition(random, size),
      );
    }

    final iterations = existingLayout == null
        ? this.iterations
        : (this.iterations * relayoutIterationsMultiplier).toInt();

    for (var step = 0; step < iterations; step++) {
      // todo - make this configurable
      // Temperature below 1 won't have any noticeable effect
      if (temp < 1) {
        break;
      }

      _runIteration(
        layoutBuilder: layoutBuilder,
        nodes: nodes,
        edges: edges,
        size: size,
        temp: temp,
      );

      temp *= 1 - (step / iterations);

      yield layoutBuilder.build();

      await Future<void>.delayed(const Duration(milliseconds: 8));
    }
  }

  void _runIteration({
    required GraphLayoutBuilder layoutBuilder,
    required Set<Node> nodes,
    required Set<Edge> edges,
    required Size size,
    required double temp,
  }) {
    final width = size.width;
    final height = size.height;
    final k = sqrt(width * height / nodes.length) / 2;

    double attraction(double x) => pow(x, 2) / k;
    double repulsion(double x) => pow(k, 2) / (x < 0.01 ? 0.01 : x);

    final displacements = {
      for (final node in nodes) node: Offset.zero,
    };

    // Calculate repulsive forces.
    for (final v in nodes) {
      for (final u in nodes) {
        if (identical(v, u)) continue;

        final delta =
            layoutBuilder.getNodePosition(v) - layoutBuilder.getNodePosition(u);
        final distance = delta.distance;

        displacements[v] =
            displacements[v]! + (delta / distance) * repulsion(distance);
      }
    }

    // Calculate attractive forces.
    for (final edge in edges) {
      final sourcePos = layoutBuilder.getNodePosition(edge.source);
      final targetPos = layoutBuilder.getNodePosition(edge.target);

      final delta = sourcePos - targetPos;
      final distance = delta.distance;

      displacements[edge.source] = displacements[edge.source]! -
          (delta / distance) * attraction(distance);
      displacements[edge.target] = displacements[edge.target]! +
          (delta / distance) * attraction(distance);
    }

    // Calculate displacement
    for (final v in nodes) {
      final displacement = displacements[v]!;

      layoutBuilder.translateNode(
        v,
        (displacement / displacement.distance) *
            min(displacement.distance, temp),
      );
    }

    // Prevent nodes from overlapping
    // for (final v in nodes) {
    //   for (final u in nodes) {
    //     if (identical(v, u)) continue;

    //     final delta = layoutBuilder.getNodePosition(v) - layoutBuilder.getNodePosition(u);
    //     final distance = delta.distance;

    //     if (distance < v.size / 2 + u.size / 2) {
    //       layoutBuilder.translateNode(v, (delta / distance) * (distance - v.size / 2 - u.size / 2));
    //     }
    //   }
    // }

    // Prevent nodes from escaping the canvas
    for (final v in nodes) {
      final position = layoutBuilder.getNodePosition(v);

      layoutBuilder.setNodePosition(
        v,
        Offset(
          position.dx.clamp(0 + v.size / 2, width - v.size / 2),
          position.dy.clamp(0 + v.size / 2, height - v.size / 2),
        ),
      );
    }
  }

  Offset _randomPosition(Random random, Size size) {
    return Offset(
      random.nextDouble() + size.width / 2,
      random.nextDouble() + size.height / 2,
    );
  }
}
