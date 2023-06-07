import 'package:flutter/foundation.dart';

@immutable
class Node {
  const Node({
    required this.data,
    required this.size,
    this.label,
  });

  final Object data;
  final double size;
  final String? label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Node &&
          runtimeType == other.runtimeType &&
          data == other.data &&
          size == other.size &&
          label == other.label;

  @override
  int get hashCode => data.hashCode ^ size.hashCode ^ label.hashCode;
}
