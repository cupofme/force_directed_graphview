## 0.6.1

- Add pub.dev shields to readme

## 0.6.0

- Add `AnimatedEdgePainter` interface
- Add `AnimatedDashEdgePainter` to draw animated dashed edges

## 0.5.0

- Center viewport by default (by @ichorid)

## 0.4.2

- Add ability to provide optimal node distance (k) for Fruchterman-Reingold algorithm (by @ichorid)

## 0.4.1

- VCF annealing for Fruchterman-Reingold algorithm (by @ichorid)

## 0.4.0

- **BREAKING**: Remove `maxDistance` parameter from `FruchtermanReingoldAlgorithm`
- **BREAKING**: Remove `loaderBuilder` parameter from `GraphView`
- Add `temperature` parameter to `FruchtermanReingoldAlgorithm`
- Make `jumpToNode` method async to ensure the graph is laid out

## 0.3.0

- **BREAKING**: Add type generic to `Edge` class
- Add `maxDistance` parameter to `FruchtermanReingoldAlgorithm`

## 0.2.0

- Implement node pinning with `controller.setPinned`
- Implement node replacement with `controller.replaceNode`
- Implement clearing the graph with `controller.clear`
- Update README.md
- Make example more usable

## 0.1.1

- Fix example link in README.md

## 0.1.0

- Initial release
