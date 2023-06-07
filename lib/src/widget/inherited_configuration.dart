import 'package:flutter/widgets.dart';
import 'package:force_directed_graphview/force_directed_graphview.dart';
import 'package:force_directed_graphview/src/configuration.dart';

class InheritedConfiguration extends InheritedWidget {
  const InheritedConfiguration({
    required this.configuration,
    required this.controller,
    required super.child,
    super.key,
  });

  final GraphViewConfiguration configuration;
  final GraphController controller;

  static GraphController controllerOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedConfiguration>()!.controller;
  }

  static GraphViewConfiguration configurationOf<T>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedConfiguration>()!.configuration;
  }

  @override
  bool updateShouldNotify(InheritedConfiguration oldWidget) =>
      oldWidget.controller != controller || oldWidget.configuration != configuration;
}
