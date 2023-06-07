import 'package:flutter/foundation.dart';
import 'package:force_directed_graphview/src/model/node.dart';

@immutable
class Edge {
  const Edge(this.source, this.target);

  final Node source;
  final Node target;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Edge && runtimeType == other.runtimeType && source == other.source && target == other.target;

  @override
  int get hashCode => source.hashCode ^ target.hashCode;
}
