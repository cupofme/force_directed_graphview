import 'package:meta/meta.dart';

/// Defines how nodes are built.
@immutable
sealed class LazyBuilding {
  /// {@macro lazy_building_strategy_none}
  const factory LazyBuilding.none() = LazyBuildingNone;

  /// {@macro lazy_building_strategy_viewport}
  const factory LazyBuilding.viewport([double scale]) = LazyBuildingViewport;
}

/// {@template lazy_building_strategy_none}
/// No lazy building is used.
/// {@endtemplate}
@immutable
final class LazyBuildingNone implements LazyBuilding {
  /// {@nodoc}
  const LazyBuildingNone();
}

/// {@template lazy_building_strategy_viewport}
/// Only nodes inside the viewport are built. The viewport is defined by
/// the visible canvas area multiplied by [scale].
/// {@endtemplate}
@immutable
final class LazyBuildingViewport implements LazyBuilding {
  /// {@nodoc}
  const LazyBuildingViewport([
    this.scale = 1.5,
  ]) : assert(scale > 0, 'Viewport scale must be greater than 0');

  /// The scale of the viewport.
  final double scale;
}
