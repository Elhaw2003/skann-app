import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:skann_app/core/di.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/core/routing/app_routes.dart';
import 'package:skann_app/features/auth/data/models/owner_registration_request.dart';
import 'package:skann_app/features/auth/data/models/login_request_model.dart';
import 'package:skann_app/features/auth/data/models/registration_response_model.dart';
import 'package:skann_app/features/auth/data/models/student_registration_request.dart';
import 'package:skann_app/features/auth/data/repositories/auth_repository.dart';
import 'package:skann_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:skann_app/features/auth/presentation/views/registration_screen.dart';
import 'package:skann_app/features/auth/presentation/views/widgets/registration_role_selector.dart';
import 'package:go_router/go_router.dart';

void main() {
  setUpAll(initializeDependencies);

  testWidgets('switches between student and owner registration fields', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_registrationApp());

    expect(find.textContaining('الجامعة'), findsOneWidget);
    expect(find.textContaining('تأكيد كلمة المرور'), findsOneWidget);

    await tester.tap(find.text('صاحب سكن'));
    await tester.pumpAndSettle();

    expect(find.textContaining('الجامعة'), findsNothing);
    expect(find.textContaining('تأكيد كلمة المرور'), findsNothing);
    expect(find.text('اختر المحافظة'), findsOneWidget);
    expect(find.text('اختر النوع'), findsOneWidget);
  });

  testWidgets('empty registration form shows validation errors', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_registrationApp());
    final submitButton = find.text('إنشاء حساب طالب والبدء');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.text('هذا الحقل مطلوب'), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('dropdown sheet searches and returns selected options', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_registrationApp());

    final genderOption = find.text('اختر النوع');
    await tester.ensureVisible(genderOption);
    await tester.tap(genderOption);
    await tester.pumpAndSettle();
    expect(find.text('اختار النوع / الجنس'), findsOneWidget);
    await tester.tap(find.text('ذكر'));
    await tester.pumpAndSettle();
    expect(find.text('تم الاختيار'), findsOneWidget);

    final governorateOption = find.text('اختر المحافظة');
    await tester.ensureVisible(governorateOption);
    await tester.tap(governorateOption);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'الجيزة');
    await tester.pumpAndSettle();
    expect(find.text('الجيزة'), findsNWidgets(2));
    await tester.tap(find.text('الجيزة').last);
    await tester.pumpAndSettle();
    expect(find.text('تم الاختيار'), findsNWidgets(2));
  });

  testWidgets('successful registration shows snackbar and opens login', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    sl.unregister<AuthCubit>();
    sl.registerFactory<AuthCubit>(
      () => AuthCubit(authRepository: _SuccessfulAuthRepository()),
    );

    final router = GoRouter(
      initialLocation: AppRoutes.register,
      routes: [
        GoRoute(
          path: AppRoutes.register,
          builder: (context, state) => const RegistrationScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) =>
              const Scaffold(body: Text('Login destination')),
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

    final cubit = tester
        .element(find.byType(RegistrationRoleSelector))
        .read<AuthCubit>();
    await cubit.registerOwner(
      const OwnerRegistrationRequest(
        fullName: 'مالك تجريبي',
        email: 'owner@example.com',
        phone: '01012345678',
        password: 'password',
        governorate: 'القاهرة',
        gender: 'MALE',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Login destination'), findsOneWidget);
    expect(
      find.text('تم إنشاء الحساب بنجاح، يمكنك تسجيل الدخول الآن'),
      findsOneWidget,
    );
  });
}

Widget _registrationApp() {
  return ScreenUtilInit(
    designSize: const Size(390, 884),
    builder: (context, child) => const MaterialApp(home: RegistrationScreen()),
  );
}

class _SuccessfulAuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, RegistrationResponseModel>> registerOwner(
    OwnerRegistrationRequest request,
  ) async {
    return Right(_registrationResponse);
  }

  @override
  Future<Either<Failure, RegistrationResponseModel>> registerStudent(
    StudentRegistrationRequest request,
  ) async {
    return Right(_registrationResponse);
  }

  @override
  Future<Either<Failure, RegistrationResponseModel>> login(
    LoginRequestModel request,
  ) async {
    return Right(_registrationResponse);
  }
}

final RegistrationResponseModel _registrationResponse =
    RegistrationResponseModel(
      success: true,
      code: 'AUTH_ACCOUNT_CREATED',
      message: 'Account created',
      data: RegistrationDataModel(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        user: UserModel(
          id: 'user-id',
          fullName: 'مالك تجريبي',
          firstName: 'مالك',
          lastName: 'تجريبي',
          email: 'owner@example.com',
          phone: '01012345678',
          role: 'OWNER',
          profileImage: null,
          bio: null,
          gender: 'MALE',
          governorate: 'القاهرة',
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
