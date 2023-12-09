# force_directed_graphview

![Pub Version](https://img.shields.io/pub/v/force_directed_graphview)
![Pub Likes](https://img.shields.io/pub/likes/force_directed_graphview)
[![CI](https://github.com/cupofme/force_directed_graphview/actions/workflows/ci.yaml/badge.svg)](https://github.com/cupofme/force_directed_graphview/actions/workflows/ci.yaml)
[![Deploy to Github Pages](https://github.com/cupofme/force_directed_graphview/actions/workflows/deploy.yaml/badge.svg?branch=main)](https://github.com/cupofme/force_directed_graphview/actions/workflows/deploy.yaml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

## [Web Demo](https://cupofme.github.io/force_directed_graphview/#/)

## Overview

A highly customizable library for displaying force-directed graphs in Flutter.

This library is primarily designed to display graphs using force-directed layouts, but it can be used for other purposes as well with the implementation of a custom layout algorithm. Currently nodes can't be dragged by gestures. The entire canvas can be dragged and zoomed using underlying [InteractiveViewer](https://api.flutter.dev/flutter/widgets/InteractiveViewer-class.html) widget.

## Usage

For example usage see [Example](https://github.com/cupofme/force_directed_graphview/blob/main/example/lib/src/screen/general_demo_screen.dart)

## Fruchterman-Reingold Algorithm scaling

Fruchterman-Reingold's got a time complexity of `O(N^2 + E)` per loop where `N` is the number of nodes and `E` is the number of edges. Simply put, it can get slow pretty fast if you have a large graph.

## License

[MIT](https://opensource.org/license/mit/)
