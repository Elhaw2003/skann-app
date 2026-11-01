import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/core/network/api_consumer.dart';
import 'package:skann_app/features/auth/data/models/registration_response_model.dart';
import 'package:skann_app/features/profile/data/repositories/profile_repository.dart';
import 'package:skann_app/features/profile/presentation/cubit/change_password_cubit.dart';
import 'package:skann_app/features/profile/presentation/cubit/change_password_state.dart';
import 'package:skann_app/features/profile/presentation/views/change_password_screen.dart';

void main() {
  final locator = GetIt.instance;

  tearDown(() async {
    await locator.reset();
  });

  group('Change password repository', () {
    test('sends the confirmed PATCH request and accepts null data', () async {
      final api = _FakeApiConsumer({
        'success': true,
        'code': 'USER_PASSWORD_UPDATED',
        'message': 'تم تغيير كلمة المرور بنجاح',
        'data': null,
      });
      final repository = ProfileRepositoryImpl(apiConsumer: api);

      final result = await repository.changePassword(
        currentPassword: ' old pass ',
        newPassword: 'new pass',
      );

      expect(api.patchPath, 'users/me/password');
      expect(api.patchData, {
        'currentPassword': ' old pass ',
        'newPassword': 'new pass',
      });
      expect(result, const Right<Failure, Unit>(unit));
    });

    test('does not report success when the API rejects the request', () async {
      final repository = ProfileRepositoryImpl(
        apiConsumer: _FakeApiConsumer({
          'success': false,
          'code': 'INVALID_CURRENT_PASSWORD',
          'message': 'كلمة المرور الحالية غير صحيحة',
          'data': null,
        }),
      );

      final result = await repository.changePassword(
        currentPassword: 'wrong',
        newPassword: 'new',
      );

      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, 'كلمة المرور الحالية غير صحيحة');
        expect(failure.code, 'INVALID_CURRENT_PASSWORD');
      }, (_) => fail('A rejected password change must not succeed.'));
    });
  });

  group('ChangePasswordCubit', () {
    test('emits loading then success after the repository succeeds', () async {
      final repository = _FakeProfileRepository(() async => const Right(unit));
      final cubit = ChangePasswordCubit(repository: repository);
      final states = <ChangePasswordState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.changePassword(currentPassword: 'old', newPassword: 'new');

      await Future<void>.delayed(Duration.zero);
      expect(states, [
        const ChangePasswordLoading(),
        const ChangePasswordSuccess(),
      ]);
      await subscription.cancel();
      await cubit.close();
    });

    test('prevents a second request while a change is in progress', () async {
      final completion = Completer<Either<Failure, Unit>>();
      final repository = _FakeProfileRepository(() => completion.future);
      final cubit = ChangePasswordCubit(repository: repository);

      final firstSubmission = cubit.changePassword(
        currentPassword: 'old',
        newPassword: 'new',
      );
      await cubit.changePassword(currentPassword: 'old', newPassword: 'newer');
      expect(repository.requestCount, 1);
      expect(cubit.state, isA<ChangePasswordLoading>());

      completion.complete(const Left(ServerFailure('Rejected')));
      await firstSubmission;
      expect(cubit.state, const ChangePasswordFailure('Rejected'));
      await cubit.close();
    });
  });

  group('Change password screen', () {
    testWidgets('validates required fields without making a request', (
      tester,
    ) async {
      final repository = _FakeProfileRepository(() async => const Right(unit));
      await _pumpScreen(tester, repository);

      final submitButton = find.widgetWithText(
        FilledButton,
        'تغيير كلمة المرور',
      );
      await tester.scrollUntilVisible(
        submitButton,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('هذا الحقل مطلوب.'), findsNWidgets(3));
      expect(repository.requestCount, 0);
    });

    testWidgets('password visibility toggles independently', (tester) async {
      await _pumpScreen(
        tester,
        _FakeProfileRepository(() async => const Right(unit)),
      );

      var fields = tester.widgetList<EditableText>(find.byType(EditableText));
      expect(fields.map((field) => field.obscureText), [true, true, true]);

      await tester.tap(find.byTooltip('إظهار كلمة المرور').first);
      await tester.pump();

      fields = tester.widgetList<EditableText>(find.byType(EditableText));
      expect(fields.map((field) => field.obscureText), [false, true, true]);
    });

    testWidgets('shows confirmation mismatch before submitting', (
      tester,
    ) async {
      final repository = _FakeProfileRepository(() async => const Right(unit));
      await _pumpScreen(tester, repository);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'old');
      await tester.enterText(fields.at(1), 'new');
      await tester.enterText(fields.at(2), 'different');
      final submitButton = find.widgetWithText(
        FilledButton,
        'تغيير كلمة المرور',
      );
      await tester.scrollUntilVisible(
        submitButton,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('كلمتا المرور غير متطابقتين.'), findsOneWidget);
      expect(repository.requestCount, 0);
    });

    testWidgets('clears fields and confirms only after success', (
      tester,
    ) async {
      final repository = _FakeProfileRepository(() async => const Right(unit));
      await _pumpScreen(tester, repository);
      await _enterValidPasswordFields(tester);
      await _submitChange(tester);

      expect(find.text('تم تغيير كلمة المرور بنجاح'), findsOneWidget);
      expect(
        tester
            .widgetList<EditableText>(find.byType(EditableText))
            .map((field) => field.controller.text),
        ['', '', ''],
      );
      expect(repository.requestCount, 1);
    });

    testWidgets('keeps entered values and shows an error on failure', (
      tester,
    ) async {
      final repository = _FakeProfileRepository(
        () async => const Left(ServerFailure('كلمة المرور الحالية غير صحيحة')),
      );
      await _pumpScreen(tester, repository);
      await _enterValidPasswordFields(tester);
      await _submitChange(tester);

      expect(find.text('كلمة المرور الحالية غير صحيحة'), findsOneWidget);
      expect(
        tester
            .widgetList<EditableText>(find.byType(EditableText))
            .map((field) => field.controller.text),
        ['old password', 'new password', 'new password'],
      );
      expect(repository.requestCount, 1);
    });
  });
}

Future<void> _enterValidPasswordFields(WidgetTester tester) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), 'old password');
  await tester.enterText(fields.at(1), 'new password');
  await tester.enterText(fields.at(2), 'new password');
}

Future<void> _submitChange(WidgetTester tester) async {
  final submitButton = find.widgetWithText(FilledButton, 'تغيير كلمة المرور');
  await tester.scrollUntilVisible(
    submitButton,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(submitButton);
  await tester.pumpAndSettle();
}

Future<void> _pumpScreen(
  WidgetTester tester,
  _FakeProfileRepository repository,
) async {
  final locator = GetIt.instance;
  await locator.reset();
  locator.registerFactory<ChangePasswordCubit>(
    () => ChangePasswordCubit(repository: repository),
  );
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(393, 852),
      builder: (context, child) =>
          const MaterialApp(home: ChangePasswordScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeApiConsumer extends ApiConsumer {
  _FakeApiConsumer(this.response);

  final Object response;
  String? patchPath;
  Object? patchData;

  @override
  Future<dynamic> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool isFromData = false,
  }) async {
    patchPath = path;
    patchData = data;
    return response;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository(this.passwordResult);

  final Future<Either<Failure, Unit>> Function() passwordResult;
  int requestCount = 0;

  @override
  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    requestCount++;
    return passwordResult();
  }

  @override
  Future<Either<Failure, UserModel>> getMyProfile() =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, UserModel>> updateProfile(
    Map<String, Object?> changes, {
    XFile? profileImage,
  }) => throw UnimplementedError();
}
