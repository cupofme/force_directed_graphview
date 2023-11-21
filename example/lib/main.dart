import 'package:example/src/screen/animated_edges_demo_screen.dart';
import 'package:example/src/screen/general_demo_screen.dart';
import 'package:example/src/screen/large_demo_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const DemoApp());
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo',
      routes: {
        '/': (context) => const DemosList(),
        '/general': (context) => const GeneralDemoScreen(),
        '/large': (context) => const LargeDemoScreen(),
        '/animated_edges': (context) => const AnimatedEdgesDemoScreen(),
      },
    );
  }
}

class DemosList extends StatelessWidget {
  const DemosList({
    super.key,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Demos'),
        ),
        body: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.graphic_eq),
              title: const Text('General'),
              onTap: () => Navigator.of(context).pushNamed('/general'),
            ),
            ListTile(
              leading: const Icon(Icons.location_searching_outlined),
              title: const Text('Large'),
              onTap: () => Navigator.of(context).pushNamed('/large'),
            ),
            ListTile(
              leading: const Icon(Icons.animation),
              title: const Text('Animated Edges'),
              onTap: () => Navigator.of(context).pushNamed('/animated_edges'),
            ),
          ],
        ),
      );
}
