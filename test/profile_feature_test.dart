import 'dart:async';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/core/network/api_consumer.dart';
import 'package:skann_app/core/services/secure_storage_helper.dart';
import 'package:skann_app/features/chat/data/repositories/chat_repository.dart';
import 'package:skann_app/features/chat/presentation/cubit/chat_unread_cubit.dart';
import 'package:skann_app/features/auth/data/models/registration_response_model.dart';
import 'package:skann_app/features/profile/data/repositories/profile_repository.dart';
import 'package:skann_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:skann_app/features/profile/presentation/cubit/profile_state.dart';
import 'package:skann_app/features/profile/presentation/views/edit_profile_screen.dart';
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

    test('parses interests returned by API as a comma-separated string', () {
      final user = UserModel.fromProfileJson({
        ..._profileData(),
        'interests': 'القراءة, الرياضة، السفر',
      });

      expect(user.interests, ['القراءة', 'الرياضة', 'السفر']);
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

    test('sends the refresh token to the logout endpoint', () async {
      final api = _FakeApiConsumer({
        'success': true,
        'code': 'AUTH_LOGOUT_SUCCESS',
        'message': 'تم تسجيل الخروج بنجاح',
        'data': null,
      });
      final repository = ProfileRepositoryImpl(apiConsumer: api);

      final result = await repository.logout(refreshToken: 'refresh-token');

      expect(api.postPath, 'auth/logout');
      expect(api.postData, {'refreshToken': 'refresh-token'});
      expect(result.isRight(), isTrue);
    });

    test(
      'does not report logout as successful for an unsuccessful response',
      () async {
        final repository = ProfileRepositoryImpl(
          apiConsumer: _FakeApiConsumer({
            'success': false,
            'code': 'AUTH_LOGOUT_FAILED',
            'message': 'تعذر تسجيل الخروج',
            'data': null,
          }),
        );

        final result = await repository.logout(refreshToken: 'refresh-token');

        expect(result.isLeft(), isTrue);
      },
    );

    test('rejects a response without profile data', () async {
      final repository = ProfileRepositoryImpl(
        apiConsumer: _FakeApiConsumer({'success': true, 'data': null}),
      );

      final result = await repository.getMyProfile();

      expect(result.isLeft(), isTrue);
    });

    test(
      'patches only the provided fields and parses updated profile',
      () async {
        final api = _FakeApiConsumer({
          'success': true,
          'code': 'USER_PROFILE_UPDATED',
          'data': {..._profileData(), 'bio': 'نبذة جديدة'},
        });
        final repository = ProfileRepositoryImpl(apiConsumer: api);

        final result = await repository.updateProfile({'bio': 'نبذة جديدة'});

        expect(api.patchPath, 'users/me');
        expect(api.patchData, {'bio': 'نبذة جديدة'});
        result.fold(
          (_) => fail('Expected profile update to succeed.'),
          (user) => expect(user.bio, 'نبذة جديدة'),
        );
      },
    );

    test('sends interests as a string', () async {
      final api = _FakeApiConsumer({
        'success': true,
        'code': 'USER_PROFILE_UPDATED',
        'data': {..._profileData(), 'interests': 'القراءة, الرياضة'},
      });
      final repository = ProfileRepositoryImpl(apiConsumer: api);

      final result = await repository.updateProfile({
        'interests': 'القراءة, الرياضة',
      });

      expect(api.patchData, {'interests': 'القراءة, الرياضة'});
      result.fold(
        (_) => fail('Expected profile update to succeed.'),
        (user) => expect(user.interests, ['القراءة', 'الرياضة']),
      );
    });

    test(
      'rejects success response when the requested value was not applied',
      () async {
        final repository = ProfileRepositoryImpl(
          apiConsumer: _FakeApiConsumer({
            'success': true,
            'code': 'USER_PROFILE_UPDATED',
            'data': _profileData(),
          }),
        );

        final result = await repository.updateProfile({'bio': 'نبذة جديدة'});

        result.fold(
          (failure) => expect(failure.code, 'PROFILE_UPDATE_NOT_APPLIED'),
          (_) => fail('An unchanged profile must not be reported as updated.'),
        );
      },
    );

    test('uploads a selected profile image as multipart data', () async {
      final api = _FakeApiConsumer({
        'success': true,
        'code': 'USER_PROFILE_UPDATED',
        'data': {
          ..._profileData(),
          'profileImage': 'https://example.com/new.png',
        },
      });
      final repository = ProfileRepositoryImpl(apiConsumer: api);

      final result = await repository.updateProfile(
        const {},
        profileImage: XFile.fromData(
          Uint8List.fromList([1, 2, 3]),
          name: 'avatar.png',
        ),
      );

      expect(result.isRight(), isTrue);
      expect(api.patchData, isA<FormData>());
      final formData = api.patchData as FormData;
      expect(formData.files, hasLength(1));
      expect(formData.files.single.key, 'profileImage');
      expect(formData.files.single.value.filename, 'profile_image.jpg');
    });

    test(
      'accepts a successful image upload when response omits image URL',
      () async {
        final repository = ProfileRepositoryImpl(
          apiConsumer: _FakeApiConsumer({
            'success': true,
            'code': 'USER_PROFILE_UPDATED',
            'data': _profileData(),
          }),
        );

        final result = await repository.updateProfile(
          const {},
          profileImage: XFile.fromData(
            Uint8List.fromList([1, 2, 3]),
            name: 'avatar.png',
          ),
        );

        expect(result.isRight(), isTrue);
      },
    );
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

    test('clears local session after server logout succeeds', () async {
      final repository = _FakeProfileRepository(
        () async => Right(UserModel.fromJson(_profileData())),
      );
      final secureStorage = _FakeSecureStorageHelper()
        ..refreshToken = 'refresh-token';
      final cubit = ProfileCubit(
        repository: repository,
        secureStorageHelper: secureStorage,
      );

      final failure = await cubit.logout();

      expect(failure, isNull);
      expect(repository.lastRefreshToken, 'refresh-token');
      expect(secureStorage.isCleared, isTrue);
      await cubit.close();
    });

    test('keeps local session when server logout fails', () async {
      final repository = _FakeProfileRepository(
        () async => Right(UserModel.fromJson(_profileData())),
      )..logoutResult = () async => const Left(NetworkFailure('offline'));
      final secureStorage = _FakeSecureStorageHelper()
        ..refreshToken = 'refresh-token';
      final cubit = ProfileCubit(
        repository: repository,
        secureStorageHelper: secureStorage,
      );

      final failure = await cubit.logout();

      expect(failure, isA<NetworkFailure>());
      expect(secureStorage.isCleared, isFalse);
      await cubit.close();
    });

    test('updates the profile using only changed fields', () async {
      final repository = _FakeProfileRepository(
        () async => Right(UserModel.fromJson(_profileData())),
      );
      repository.updateResult = () async => Right(
        UserModel.fromProfileJson({..._profileData(), 'bio': 'نبذة محدثة'}),
      );
      final cubit = ProfileCubit(
        repository: repository,
        secureStorageHelper: _FakeSecureStorageHelper(),
      );
      await cubit.load();

      final failure = await cubit.updateProfile({'bio': 'نبذة محدثة'});

      expect(failure, isNull);
      expect(repository.lastChanges, {'bio': 'نبذة محدثة'});
      expect((cubit.state as ProfileLoaded).user.bio, 'نبذة محدثة');
      await cubit.close();
    });

    test('reloads profile after successful image upload', () async {
      var uploaded = false;
      final repository = _FakeProfileRepository(
        () async => Right(
          UserModel.fromProfileJson({
            ..._profileData(),
            'profileImage': uploaded ? 'https://example.com/new.png' : null,
          }),
        ),
      );
      repository.updateResult = () async {
        uploaded = true;
        return Right(UserModel.fromProfileJson(_profileData()));
      };
      final cubit = ProfileCubit(
        repository: repository,
        secureStorageHelper: _FakeSecureStorageHelper(),
      );
      await cubit.load();

      final failure = await cubit.updateProfile(
        const {},
        profileImage: XFile.fromData(
          Uint8List.fromList([1, 2, 3]),
          name: 'avatar.png',
        ),
      );

      expect(failure, isNull);
      expect(
        (cubit.state as ProfileLoaded).user.profileImage,
        'https://example.com/new.png',
      );
      expect(repository.requestCount, 2);
      await cubit.close();
    });

    test('does not show an image locally when server returns null', () async {
      final user = UserModel.fromProfileJson(_profileData());
      final repository = _FakeProfileRepository(() async => Right(user));
      repository.updateResult = () async => Right(user);
      final cubit = ProfileCubit(
        repository: repository,
        secureStorageHelper: _FakeSecureStorageHelper(),
      );
      await cubit.load();

      final failure = await cubit.updateProfile(
        const {},
        profileImage: XFile.fromData(
          Uint8List.fromList([4, 5, 6]),
          name: 'avatar.png',
        ),
      );

      expect(failure?.code, 'PROFILE_IMAGE_NOT_CONFIRMED');
      final loadedState = cubit.state as ProfileLoaded;
      expect(loadedState.user.profileImage, isNull);
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
          home: MultiBlocProvider(
            providers: [
              BlocProvider<ProfileCubit>.value(value: cubit),
              BlocProvider(
                create: (_) => ChatUnreadCubit(
                  repository: _UnusedChatRepository(),
                  secureStorageHelper: _FakeSecureStorageHelper(),
                ),
              ),
            ],
            child: const ProfileView(),
          ),
        ),
      ),
    );

    expect(find.text('مريم أحمد'), findsOneWidget);
    expect(find.text('جامعة القاهرة'), findsOneWidget);
    expect(find.text('طالب سكن'), findsOneWidget);
    expect(find.text('الملف الشخصي'), findsOneWidget);
    expect(find.text('تعديل البيانات الشخصية'), findsOneWidget);
    expect(find.text('زملاء السكن'), findsOneWidget);
    expect(find.text('نبذة عني'), findsNothing);
  });

  testWidgets('requires confirmation before logging out', (tester) async {
    final cubit = ProfileCubit(
      repository: _FakeProfileRepository(
        () async => Right(UserModel.fromProfileJson(_profileData())),
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
          home: MultiBlocProvider(
            providers: [
              BlocProvider<ProfileCubit>.value(value: cubit),
              BlocProvider(
                create: (_) => ChatUnreadCubit(
                  repository: _UnusedChatRepository(),
                  secureStorageHelper: _FakeSecureStorageHelper(),
                ),
              ),
            ],
            child: const ProfileView(),
          ),
        ),
      ),
    );

    await tester.scrollUntilVisible(find.text('تسجيل الخروج'), 350);
    await tester.tap(find.text('تسجيل الخروج'));
    await tester.pumpAndSettle();

    expect(find.text('هل أنت متأكد من تسجيل الخروج؟'), findsOneWidget);
    await tester.tap(find.text('البقاء'));
    await tester.pumpAndSettle();
    expect(find.text('هل أنت متأكد من تسجيل الخروج؟'), findsNothing);
    expect(cubit.state, isA<ProfileLoaded>());
  });

  testWidgets('shows logout failures in a snackbar', (tester) async {
    final repository =
        _FakeProfileRepository(
            () async => Right(UserModel.fromProfileJson(_profileData())),
          )
          ..logoutResult = () async =>
              const Left(NetworkFailure('تعذر الاتصال بالإنترنت.'));
    final cubit = ProfileCubit(
      repository: repository,
      secureStorageHelper: _FakeSecureStorageHelper()
        ..refreshToken = 'refresh-token',
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
          home: MultiBlocProvider(
            providers: [
              BlocProvider<ProfileCubit>.value(value: cubit),
              BlocProvider(
                create: (_) => ChatUnreadCubit(
                  repository: _UnusedChatRepository(),
                  secureStorageHelper: _FakeSecureStorageHelper(),
                ),
              ),
            ],
            child: const ProfileView(),
          ),
        ),
      ),
    );

    await tester.scrollUntilVisible(find.text('تسجيل الخروج'), 350);
    await tester.tap(find.text('تسجيل الخروج'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تسجيل الخروج').last);
    await tester.pumpAndSettle();

    expect(
      find.text('تعذر الاتصال بالإنترنت. تحقق من اتصالك وحاول مرة أخرى.'),
      findsOneWidget,
    );
    expect(find.text('هل أنت متأكد من تسجيل الخروج؟'), findsNothing);
  });

  testWidgets('profile editor selects governorates from registration options', (
    tester,
  ) async {
    final user = UserModel.fromProfileJson(_profileData());
    final cubit = ProfileCubit(
      repository: _FakeProfileRepository(() async => Right(user)),
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
          home: EditProfileScreen(
            arguments: ProfileEditRouteData(cubit: cubit, user: user),
          ),
        ),
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -450));
    await tester.pumpAndSettle();

    expect(find.text('الجيزة'), findsOneWidget);
    await tester.tap(find.text('الجيزة'));
    await tester.pumpAndSettle();
    expect(find.text('النوع / الجنس'), findsOneWidget);
    await tester.tap(find.text('القاهرة'));
    await tester.pumpAndSettle();
    expect(find.text('القاهرة'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -3000));
    await tester.pumpAndSettle();
    expect(find.text('تغيير كلمة المرور'), findsOneWidget);
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
  String? postPath;
  Object? postData;
  String? patchPath;
  Object? patchData;

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
  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool isFromData = false,
  }) async {
    postPath = path;
    postData = data;
    return response;
  }

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
  _FakeProfileRepository(this.result);

  Future<Either<Failure, UserModel>> Function() result;
  Future<Either<Failure, UserModel>> Function()? updateResult;
  Future<Either<Failure, Unit>> Function()? logoutResult;
  int requestCount = 0;
  Map<String, Object?>? lastChanges;
  String? lastRefreshToken;

  @override
  Future<Either<Failure, UserModel>> getMyProfile() {
    requestCount++;
    return result();
  }

  @override
  Future<Either<Failure, UserModel>> updateProfile(
    Map<String, Object?> changes, {
    XFile? profileImage,
  }) {
    lastChanges = changes;
    return updateResult?.call() ?? result();
  }

  @override
  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> logout({required String refreshToken}) {
    lastRefreshToken = refreshToken;
    return logoutResult?.call() ?? Future.value(const Right(unit));
  }
}

class _FakeSecureStorageHelper extends SecureStorageHelper {
  _FakeSecureStorageHelper() : super.internal();

  bool isCleared = false;
  String? refreshToken;

  @override
  Future<String?> getRefreshToken() async => refreshToken;

  @override
  Future<void> clearTokens() async {
    isCleared = true;
  }
}

class _UnusedChatRepository implements ChatRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
