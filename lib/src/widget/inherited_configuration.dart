import 'package:flutter/widgets.dart';
import 'package:force_directed_graphview/force_directed_graphview.dart';
import 'package:force_directed_graphview/src/configuration.dart';

/// An InheritedWidget that provides [GraphViewConfiguration]
/// and [GraphController] down to the widget tree
class InheritedConfiguration extends InheritedWidget {
  /// { @nodoc }
  const InheritedConfiguration({
    required this.configuration,
    required this.controller,
    required super.child,
    super.key,
  });

  /// { @nodoc }
  final GraphViewConfiguration configuration;

  /// { @nodoc }
  final GraphController controller;

  /// { @nodoc }
  static GraphController controllerOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<InheritedConfiguration>()!
        .controller;
  }

  /// { @nodoc }
  static GraphViewConfiguration configurationOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<InheritedConfiguration>()!
        .configuration;
  }

  @override
  bool updateShouldNotify(InheritedConfiguration oldWidget) =>
      oldWidget.controller != controller ||
      oldWidget.configuration != configuration;
}
