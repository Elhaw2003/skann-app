import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:skann_app/core/di.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/core/routing/app_routes.dart';
import 'package:skann_app/features/auth/data/models/login_request_model.dart';
import 'package:skann_app/features/auth/data/models/owner_registration_request.dart';
import 'package:skann_app/features/auth/data/models/registration_response_model.dart';
import 'package:skann_app/features/auth/data/models/student_registration_request.dart';
import 'package:skann_app/features/auth/data/repositories/auth_repository.dart';
import 'package:skann_app/features/auth/presentation/views/login_screen.dart';

void main() {
  setUpAll(initializeDependencies);

  testWidgets('validates fields and submits login credentials', (tester) async {
    final repository = _LoginAuthRepository();
    sl.unregister<AuthRepository>();
    sl.registerSingleton<AuthRepository>(repository);
    addTearDown(() => sl.unregister<AuthRepository>());
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = GoRouter(
      initialLocation: AppRoutes.login,
      routes: [
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.studentHome,
          builder: (context, state) =>
              const Scaffold(body: Text('Student home destination')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 884),
        builder: (context, child) => MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.tap(find.text('تسجيل الدخول').last);
    await tester.pump();
    expect(find.text('يرجى إدخال البريد الإلكتروني'), findsOneWidget);
    expect(repository.request, isNull);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'student@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'Password123');
    await tester.tap(find.text('تسجيل الدخول').last);
    await tester.pumpAndSettle();

    expect(repository.request?.email, 'student@example.com');
    expect(repository.request?.password, 'Password123');
    expect(find.text('Student home destination'), findsOneWidget);
  });
}

class _LoginAuthRepository implements AuthRepository {
  LoginRequestModel? request;

  @override
  Future<Either<Failure, RegistrationResponseModel>> login(
    LoginRequestModel request,
  ) async {
    this.request = request;
    return Right(_loginResponse);
  }

  @override
  Future<Either<Failure, RegistrationResponseModel>> registerOwner(
    OwnerRegistrationRequest request,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, RegistrationResponseModel>> registerStudent(
    StudentRegistrationRequest request,
  ) async {
    throw UnimplementedError();
  }
}

final RegistrationResponseModel _loginResponse = RegistrationResponseModel(
  success: true,
  code: 'AUTH_LOGIN_SUCCESS',
  message: 'تم تسجيل الدخول بنجاح',
  data: RegistrationDataModel(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    user: UserModel(
      id: 'user-id',
      fullName: 'طالب تجريبي',
      firstName: 'طالب',
      lastName: 'تجريبي',
      email: 'student@example.com',
      phone: '01012345678',
      role: 'STUDENT',
      profileImage: null,
      bio: null,
      gender: null,
      governorate: null,
      university: null,
      faculty: null,
      major: null,
      academicYear: null,
      housingStatus: null,
      interests: null,
      isActive: true,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    ),
  ),
);
