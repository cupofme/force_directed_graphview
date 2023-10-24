import 'dart:math';
import 'dart:ui';

import 'package:force_directed_graphview/force_directed_graphview.dart';

/// A function that extracts the initial position of the node
typedef InitialNodePositionExtractor = Offset Function(
  NodeBase node,
  Size canvasSize,
);

/// An implementation of Fruchterman-Reingold algorithm
class FruchtermanReingoldAlgorithm implements GraphLayoutAlgorithm {
  /// Creates a new instance of [FruchtermanReingoldAlgorithm]
  const FruchtermanReingoldAlgorithm({
    this.iterations = 100,
    this.relayoutIterationsMultiplier = 0.1,
    this.showIterations = false,
    this.initialPositionExtractor = defaultInitialPositionExtractor,
  });

  /// The number of iterations to run the algorithm
  final int iterations;

  /// The coefficient for number of iterations to run when relayouting
  final double relayoutIterationsMultiplier;

  /// If true, the algorithm will emit intermediate layouts as it runs
  final bool showIterations;

  /// The function that extracts the initial position of the node
  final InitialNodePositionExtractor initialPositionExtractor;

  @override
  Stream<GraphLayout> layout({
    required Set<NodeBase> nodes,
    required Set<EdgeBase> edges,
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
    required Set<NodeBase> nodes,
    required Set<EdgeBase> edges,
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
    required Set<NodeBase> nodes,
    required Set<EdgeBase> edges,
    required Size size,
    required GraphLayout? existingLayout,
  }) async* {
    var temp = sqrt(size.width / 2 * size.height / 2) / 20;

    final layoutBuilder = GraphLayoutBuilder(
      nodes: nodes,
    );

    for (final node in nodes) {
      layoutBuilder.setNodePosition(
        node,
        existingLayout?.getPositionOrNull(node) ??
            initialPositionExtractor(node, size),
      );
    }

    final iterations = existingLayout == null
        ? this.iterations
        : (this.iterations * relayoutIterationsMultiplier).toInt();

    for (var step = 0; step < iterations; step++) {
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

      if (showIterations) {
        yield layoutBuilder.build();
      }

      // To prevent the UI from freezing
      await Future<void>.delayed(Duration.zero);
    }

    if (!showIterations) {
      yield layoutBuilder.build();
    }
  }

  void _runIteration({
    required GraphLayoutBuilder layoutBuilder,
    required Set<NodeBase> nodes,
    required Set<EdgeBase> edges,
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
      final destPos = layoutBuilder.getNodePosition(edge.destination);

      final delta = sourcePos - destPos;
      final distance = delta.distance;

      displacements[edge.source] = displacements[edge.source]! -
          (delta / distance) * attraction(distance);
      displacements[edge.destination] = displacements[edge.destination]! +
          (delta / distance) * attraction(distance);
    }

    // Calculate displacement
    for (final v in nodes) {
      final displacement = displacements[v]!;

      if (v.pinned) continue;

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

    //     final delta =
    //         layoutBuilder.getNodePosition(v) -
    //          layoutBuilder.getNodePosition(u);
    //     final distance = delta.distance;

    //     if (distance < v.size / 2 + u.size / 2) {
    //       layoutBuilder.translateNode(
    //         v,
    //         (delta / distance) * (distance - v.size / 2 - u.size / 2),
    //       );
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

  /// The default implementation of [initialPositionExtractor]
  static Offset defaultInitialPositionExtractor(
    NodeBase node,
    Size canvasSize,
  ) {
    final random = Random(node.hashCode);

    // Just a small initial offset is enough
    return Offset(
      random.nextDouble() + canvasSize.width / 2,
      random.nextDouble() + canvasSize.height / 2,
    );
  }
}
