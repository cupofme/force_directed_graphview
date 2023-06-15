import 'package:flutter/widgets.dart';

/// Configuration for a label, used by [LabelBuilder].
/// Necessary to determine the size of the label in build time.
class LabelConfiguration {
  const LabelConfiguration({
    required this.child,
    required this.size,
  });

  final Widget child;
  final Size size;
}
