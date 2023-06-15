import 'package:flutter/widgets.dart';
import 'package:force_directed_graphview/src/model/builders.dart';

/// Configuration for a label, used by [LabelBuilder].
/// Necessary to determine the size of the label in build time.
class LabelConfiguration {
  const LabelConfiguration({
    required this.child,
    required this.size,
  });

  /// The child widget of the label.
  final Widget child;

  /// Maximum size of the label. Used as a an argument to [BoxConstraints.loose]
  final Size size;
}
