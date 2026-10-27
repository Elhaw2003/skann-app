import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:skann_app/core/routing/app_routes.dart';
import 'package:skann_app/core/services/secure_storage_helper.dart';
import 'package:skann_app/features/splash/presentation/view/splash_screen.dart';

void main() {
  testWidgets('restores a saved student session directly to home', (
    tester,
  ) async {
    final router = _createRouter(
      _FakeSecureStorageHelper(hasToken: true, userType: 'STUDENT'),
    );
    addTearDown(router.dispose);

    await _pumpSplash(tester, router);

    expect(find.text('Student home'), findsOneWidget);
  });

  testWidgets('opens login when there is no saved access token', (
    tester,
  ) async {
    final router = _createRouter(
      _FakeSecureStorageHelper(hasToken: false, userType: 'STUDENT'),
    );
    addTearDown(router.dispose);

    await _pumpSplash(tester, router);

    expect(find.text('Login'), findsOneWidget);
  });
}

GoRouter _createRouter(SecureStorageHelper storageHelper) => GoRouter(
  initialLocation: AppRoutes.spalshScreen,
  routes: [
    GoRoute(
      path: AppRoutes.spalshScreen,
      builder: (context, state) =>
          SplashScreen(secureStorageHelper: storageHelper),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const Scaffold(body: Text('Login')),
    ),
    GoRoute(
      path: AppRoutes.studentHome,
      builder: (context, state) => const Scaffold(body: Text('Student home')),
    ),
  ],
);

Future<void> _pumpSplash(WidgetTester tester, GoRouter router) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(390, 884),
      builder: (context, child) => MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pump(const Duration(seconds: 4));
  await tester.pumpAndSettle();
}

class _FakeSecureStorageHelper extends SecureStorageHelper {
  _FakeSecureStorageHelper({required this.hasToken, required this.userType})
    : super.internal();

  final bool hasToken;
  final String? userType;

  @override
  Future<bool> isLoggedIn() async => hasToken;

  @override
  Future<String?> getUserType() async => userType;
}
