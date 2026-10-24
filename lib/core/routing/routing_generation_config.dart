import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skann_app/core/routing/app_routes.dart';
import 'package:skann_app/features/splash/presentation/view/splash_screen.dart';

class RoutingGenerationConfig {
  static GoRouter routerGeneratorConfig = GoRouter(
    initialLocation: AppRoutes.spalshScreen,
    errorBuilder: (context, state) => errorBuilder(),
    routes: [
      // ================================================================
      // PRE-AUTH ROUTES
      // ================================================================
      GoRoute(
        path: AppRoutes.spalshScreen,
        name: AppRoutes.spalshScreen,
        builder: (context, state) => const SplashScreen(),
      ),
    ],
  );
}

Widget errorBuilder() {
  return Scaffold(
    appBar: AppBar(
      centerTitle: true,
      backgroundColor: Colors.red,
      title: const Text("Error Screen"),
    ),
    body: const Center(child: Text("No Page Found")),
  );
}
