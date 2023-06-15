import 'package:flutter/foundation.dart';

@immutable
class Node {
  const Node({
    required this.data,
    required this.size,
  });

  final Object data;
  final double size;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Node &&
          runtimeType == other.runtimeType &&
          data == other.data &&
          size == other.size;

  @override
  int get hashCode => data.hashCode ^ size.hashCode;
}
