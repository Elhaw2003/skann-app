import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/core/network/api_consumer.dart';
import 'package:skann_app/core/services/secure_storage_helper.dart';
import 'package:skann_app/features/auth/data/models/registration_response_model.dart';
import 'package:skann_app/features/profile/data/repositories/profile_repository.dart';
import 'package:skann_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:skann_app/features/profile/presentation/cubit/profile_state.dart';
import 'package:skann_app/features/profile/presentation/views/widgets/profile_view.dart';

void main() {
  group('User profile model and repository', () {
    test('parses available profile fields and safely parses interests', () {
      final user = UserModel.fromJson(_profileData());

      expect(user.displayName, 'مريم أحمد');
      expect(user.role, 'STUDENT');
      expect(user.interests, ['القراءة', 'الرياضة']);
      expect(user.createdAt, DateTime.utc(2026, 9, 7, 14, 37, 40, 162));
    });

    test('supports null, missing, and malformed optional profile fields', () {
      final user = UserModel.fromProfileJson({
        'role': 'STUDENT',
        'profileImage': null,
        'interests': null,
        'isActive': 'unknown',
        'createdAt': 'not-a-date',
      });

      expect(user.id, isNull);
      expect(user.displayName, isEmpty);
      expect(user.profileImage, isNull);
      expect(user.interests, isNull);
      expect(user.isActive, isNull);
      expect(user.createdAt, isNull);
      expect(user.university, isNull);
    });

    test(
      'requests the authenticated profile endpoint and parses its envelope',
      () async {
        final api = _FakeApiConsumer({
          'success': true,
          'code': 'USER_PROFILE_RETRIEVED',
          'data': _profileData(),
        });
        final repository = ProfileRepositoryImpl(apiConsumer: api);

        final result = await repository.getMyProfile();

        expect(api.getPath, 'users/me');
        result.fold(
          (_) => fail('Expected profile to load.'),
          (user) => expect(user.fullName, 'مريم أحمد'),
        );
      },
    );

    test('rejects a response without profile data', () async {
      final repository = ProfileRepositoryImpl(
        apiConsumer: _FakeApiConsumer({'success': true, 'data': null}),
      );

      final result = await repository.getMyProfile();

      expect(result.isLeft(), isTrue);
    });
  });

  group('ProfileCubit', () {
    test(
      'loads the profile and avoids duplicate concurrent requests',
      () async {
        final completion = Completer<Either<Failure, UserModel>>();
        final repository = _FakeProfileRepository(() => completion.future);
        final cubit = ProfileCubit(
          repository: repository,
          secureStorageHelper: _FakeSecureStorageHelper(),
        );

        final firstLoad = cubit.load();
        await cubit.load();
        expect(cubit.state, isA<ProfileLoading>());
        expect(repository.requestCount, 1);

        completion.complete(Right(UserModel.fromJson(_profileData())));
        await firstLoad;
        expect(cubit.state, isA<ProfileLoaded>());
        await cubit.close();
      },
    );

    test('preserves profile data if refresh fails', () async {
      final repository = _FakeProfileRepository(
        () async => Right(UserModel.fromJson(_profileData())),
      );
      final cubit = ProfileCubit(
        repository: repository,
        secureStorageHelper: _FakeSecureStorageHelper(),
      );

      await cubit.load();
      repository.result = () async => const Left(NetworkFailure('offline'));
      await cubit.refresh();

      expect(cubit.state, isA<ProfileLoaded>());
      final state = cubit.state as ProfileLoaded;
      expect(state.user.fullName, 'مريم أحمد');
      expect(state.isRefreshing, isFalse);
      expect(state.refreshError, isNotNull);
      await cubit.close();
    });

    test('represents authentication failure distinctly', () async {
      final cubit = ProfileCubit(
        repository: _FakeProfileRepository(
          () async => const Left(AuthFailure('unauthorized')),
        ),
        secureStorageHelper: _FakeSecureStorageHelper(),
      );

      await cubit.load();

      expect(cubit.state, isA<ProfileFailure>());
      expect((cubit.state as ProfileFailure).requiresLogin, isTrue);
      await cubit.close();
    });
  });

  testWidgets('renders returned profile data and safe optional fields', (
    tester,
  ) async {
    final cubit = ProfileCubit(
      repository: _FakeProfileRepository(
        () async => Right(
          UserModel.fromProfileJson({
            'role': 'STUDENT',
            'fullName': 'مريم أحمد',
            'university': 'جامعة القاهرة',
            'profileImage': null,
            'interests': [],
          }),
        ),
      ),
      secureStorageHelper: _FakeSecureStorageHelper(),
    );
    await cubit.load();
    addTearDown(cubit.close);

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 884),
        builder: (context, child) => MaterialApp(
          home: BlocProvider.value(value: cubit, child: const ProfileView()),
        ),
      ),
    );

    expect(find.text('مريم أحمد'), findsOneWidget);
    expect(find.text('جامعة القاهرة'), findsOneWidget);
    expect(find.text('طالب سكن'), findsOneWidget);
    expect(find.text('الملف الشخصي'), findsOneWidget);
    expect(find.text('نبذة عني'), findsNothing);
  });
}

Map<String, dynamic> _profileData() => {
  'id': 'user-id',
  'fullName': 'مريم أحمد',
  'firstName': 'مريم',
  'lastName': 'أحمد',
  'email': 'student@example.com',
  'phone': '01011112222',
  'role': 'STUDENT',
  'profileImage': null,
  'bio': 'أحب القراءة والتعلم',
  'gender': 'FEMALE',
  'governorate': 'الجيزة',
  'university': 'جامعة القاهرة',
  'faculty': 'الهندسة',
  'major': 'هندسة مدنية',
  'academicYear': 'السنة الثالثة',
  'housingStatus': null,
  'interests': ['القراءة', 'الرياضة'],
  'isActive': true,
  'createdAt': '2026-09-07T14:37:40.162Z',
  'updatedAt': '2026-09-07T14:37:40.162Z',
};

class _FakeApiConsumer extends ApiConsumer {
  _FakeApiConsumer(this.response);

  final Object? response;
  String? getPath;

  @override
  Future<dynamic> get(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    getPath = path;
    return response;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository(this.result);

  Future<Either<Failure, UserModel>> Function() result;
  int requestCount = 0;

  @override
  Future<Either<Failure, UserModel>> getMyProfile() {
    requestCount++;
    return result();
  }
}

class _FakeSecureStorageHelper extends SecureStorageHelper {
  _FakeSecureStorageHelper() : super.internal();

  bool isCleared = false;

  @override
  Future<void> clearTokens() async {
    isCleared = true;
  }
}
