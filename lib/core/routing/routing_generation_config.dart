import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skann_app/core/routing/app_routes.dart';
import 'package:skann_app/features/auth/presentation/views/login_screen.dart';
import 'package:skann_app/features/auth/presentation/views/registration_screen.dart';
import 'package:skann_app/features/splash/presentation/view/splash_screen.dart';
import 'package:skann_app/features/home/presentation/views/student_home_screen.dart';
import 'package:skann_app/features/property_details/presentation/views/property_details_screen.dart';
import 'package:skann_app/features/room_details/presentation/views/room_details_screen.dart';

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
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: AppRoutes.register,
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentHome,
        name: AppRoutes.studentHome,
        builder: (context, state) => const StudentHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.propertyDetails,
        name: AppRoutes.propertyDetails,
        builder: (context, state) => PropertyDetailsScreen(
          propertyId: state.pathParameters['propertyId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.roomDetails,
        name: AppRoutes.roomDetails,
        builder: (context, state) =>
            RoomDetailsScreen(roomId: state.pathParameters['roomId'] ?? ''),
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
