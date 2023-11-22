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
    this.temperature,
    this.optimalDistance,
  });

  /// The number of iterations to run the algorithm
  final int iterations;

  /// The coefficient for number of iterations to run when relayouting
  final double relayoutIterationsMultiplier;

  /// If true, the algorithm will emit intermediate layouts as it runs
  final bool showIterations;

  /// The function that extracts the initial position of the node
  final InitialNodePositionExtractor initialPositionExtractor;

  /// The temperature of the algorithm. If null, it will be calculated by `sqrt(size.width / 2 * size.height / 2) / 30`
  final double? temperature;

  /// Optimal distance between nodes (k)
  final double? optimalDistance;

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
    var temp = temperature ?? sqrt(size.width / 2 * size.height / 2) / 30;
    final k = optimalDistance ?? sqrt(size.width * size.height / nodes.length);

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
        k: k,
      );
      // Lundy & Mees annealing coefficient model
      // temp = temp / (1 + 0.0001 * temp);

      // Annealing schedule inspired by VCF by Peprah, Appiah, Amponash 2017
      final vc = nodes.length * 2;
      temp *= 1 / (1 + 1 / (sqrt(step * (vc + 1) + vc)));

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
    required double k, // Optimal distance between nodes (k)
  }) {
    final width = size.width;
    final height = size.height;
    final repulsionDistanceCutoff = k * 3; // Seems to work the best
    final kSquared = k * k;

    double attraction(double x) => x * x / k;
    double clampDistance(double x) => (x < 0.01 ? 0.01 : x);

    final displacements = {
      for (final node in nodes) node: Offset.zero,
    };

    // Calculate repulsive forces.
    final nodesList = nodes.toList();
    for (var i = 0; i < nodesList.length; i++) {
      for (var j = i + 1; j < nodesList.length; j++) {
        if (i == j) continue;
        final u = nodesList[i];
        final v = nodesList[j];

        final positionV = layoutBuilder.getNodePosition(v);
        final delta = positionV - layoutBuilder.getNodePosition(u);
        final distance = clampDistance(delta.distance);
        if (distance > repulsionDistanceCutoff) continue;

        final disp = (delta * kSquared) / (distance * distance);
        displacements[v] = displacements[v]! + disp;
        displacements[u] = displacements[u]! - disp;
      }
    }

    // Calculate attractive forces.
    for (final edge in edges) {
      final sourcePos = layoutBuilder.getNodePosition(edge.source);
      final destPos = layoutBuilder.getNodePosition(edge.destination);

      final delta = sourcePos - destPos;
      final distance = delta.distance;

      final disp = (delta / distance) * attraction(distance);
      displacements[edge.source] = displacements[edge.source]! - disp;
      displacements[edge.destination] = displacements[edge.destination]! + disp;
    }

    // Calculate displacement
    for (final v in nodes) {
      final displacement = displacements[v]!;

      if (v.pinned) continue;

      // Not worth moving
      if (displacement.distance < repulsionDistanceCutoff / 30) continue;

      final translationDelta = (displacement / displacement.distance) *
          min(displacement.distance, temp);

      layoutBuilder.translateNode(v, translationDelta);
    }

    // Prevent nodes from escaping the canvas
    for (final v in nodes) {
      final position = layoutBuilder.getNodePosition(v);

      layoutBuilder.setNodePosition(
        v,
        Offset(
          position.dx.clamp(v.size / 2, width - v.size / 2),
          position.dy.clamp(v.size / 2, height - v.size / 2),
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
