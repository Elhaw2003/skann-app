import 'package:flutter/material.dart';
import 'package:skann_app/core/routing/routing_generation_config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      routerConfig: RoutingGenerationConfig.routerGeneratorConfig,
    );
  }
}
