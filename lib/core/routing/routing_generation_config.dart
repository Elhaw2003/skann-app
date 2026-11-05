import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skann_app/core/di.dart';
import 'package:skann_app/core/routing/app_routes.dart';
import 'package:skann_app/core/services/secure_storage_helper.dart';
import 'package:skann_app/features/auth/presentation/views/login_screen.dart';
import 'package:skann_app/features/auth/presentation/views/registration_screen.dart';
import 'package:skann_app/features/splash/presentation/view/splash_screen.dart';
import 'package:skann_app/features/home/presentation/views/student_home_screen.dart';
import 'package:skann_app/features/property_details/presentation/views/property_details_screen.dart';
import 'package:skann_app/features/profile/presentation/views/profile_screen.dart';
import 'package:skann_app/features/profile/presentation/views/edit_profile_screen.dart';
import 'package:skann_app/features/profile/presentation/views/change_password_screen.dart';
import 'package:skann_app/features/room_details/presentation/views/room_details_screen.dart';
import 'package:skann_app/features/matching_roommates/presentation/views/roommates_screen.dart';
import 'package:skann_app/features/booking_requests/data/models/booking_request_model.dart';
import 'package:skann_app/features/booking_requests/presentation/views/booking_request_details_screen.dart';
import 'package:skann_app/features/booking_requests/presentation/views/booking_request_screen.dart';
import 'package:skann_app/features/booking_requests/presentation/views/my_bookings_screen.dart';

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
        builder: (context, state) =>
            SplashScreen(secureStorageHelper: sl<SecureStorageHelper>()),
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
        path: AppRoutes.profile,
        name: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        name: AppRoutes.editProfile,
        builder: (context, state) {
          final arguments = state.extra;
          if (arguments is! ProfileEditRouteData) return errorBuilder();
          return EditProfileScreen(arguments: arguments);
        },
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        name: AppRoutes.changePassword,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.matchingRoommates,
        name: AppRoutes.matchingRoommates,
        builder: (context, state) => const RoommatesScreen(),
      ),
      GoRoute(
        path: AppRoutes.roommates,
        name: AppRoutes.roommates,
        builder: (context, state) => const RoommatesScreen(),
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
      GoRoute(
        path: AppRoutes.myBookings,
        name: AppRoutes.myBookings,
        builder: (context, state) => const MyBookingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.createBookingRequest,
        name: AppRoutes.createBookingRequest,
        builder: (context, state) {
          final arguments = state.extra;
          if (arguments is! BookingRequestRouteData) return errorBuilder();
          return BookingRequestScreen(
            property: arguments.property,
            room: arguments.room,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.bookingRequestDetails,
        name: AppRoutes.bookingRequestDetails,
        builder: (context, state) {
          final booking = state.extra;
          if (booking is! BookingRequestModel) return errorBuilder();
          return BookingRequestDetailsScreen(booking: booking);
        },
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
