import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skann_app/core/errors/dio_exceptions.dart';
import 'package:skann_app/core/errors/exceptions.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/core/network/api_consumer.dart';
import 'package:skann_app/core/services/secure_storage_helper.dart';
import 'package:skann_app/features/auth/data/models/owner_registration_request.dart';
import 'package:skann_app/features/auth/data/models/login_request_model.dart';
import 'package:skann_app/features/auth/data/models/registration_response_model.dart';
import 'package:skann_app/features/auth/data/models/student_registration_request.dart';
import 'package:skann_app/features/auth/data/repositories/auth_repository.dart';
import 'package:skann_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:skann_app/features/auth/presentation/cubit/auth_states.dart';

void main() {
  group('registration requests', () {
    test('owner body contains only owner fields', () {
      final body = _ownerRequest().toJson();

      expect(body.keys.toSet(), {
        'fullName',
        'email',
        'phone',
        'password',
        'role',
        'governorate',
        'gender',
      });
      expect(body['role'], 'OWNER');
      expect(body.containsKey('confirmPassword'), isFalse);
      expect(body.containsKey('university'), isFalse);
    });

    test('request models use Equatable value equality', () {
      expect(_ownerRequest(), _ownerRequest());
      expect(_studentRequest(), _studentRequest());
      expect(_ownerRequest(), isA<Equatable>());
      expect(_studentRequest(), isA<Equatable>());
    });

    test('student body includes confirmation and academic fields', () {
      final body = _studentRequest().toJson();

      expect(body.keys.toSet(), {
        'fullName',
        'email',
        'phone',
        'password',
        'confirmPassword',
        'role',
        'gender',
        'governorate',
        'university',
        'faculty',
        'major',
        'academicYear',
      });
      expect(body['role'], 'STUDENT');
      expect(body['confirmPassword'], body['password']);
    });
  });

  test(
    'response parses nullable owner profile and preserves interests type',
    () {
      final response = RegistrationResponseModel.fromJson(_successResponse());

      expect(response.success, isTrue);
      expect(response.code, 'AUTH_ACCOUNT_CREATED');
      expect(response.data.user.profileImage, isNull);
      expect(response.data.user.university, isNull);
      expect(response.data.user.interests, isA<List<Object?>>());
      expect(response.data.user.createdAt, DateTime.utc(2026, 10, 26));
      expect(RegistrationResponseModel.fromJson(_successResponse()), response);
      expect(response.data.user, isA<Equatable>());
    },
  );

  test('server error parsing falls back to the HTTP status code', () {
    final error = parseErrorResponse({'message': 'Conflict'}, 409);

    expect(error.statusCode, 409);
  });

  test(
    'repository posts to shared endpoint and saves returned tokens',
    () async {
      final apiConsumer = _FakeApiConsumer(_successResponse());
      final secureStorageHelper = _FakeSecureStorageHelper();
      final repository = AuthRepositoryImpl(
        apiConsumer: apiConsumer,
        secureStorageHelper: secureStorageHelper,
      );

      final response = await repository.registerOwner(_ownerRequest());

      expect(apiConsumer.requestPath, 'auth/register');
      expect(apiConsumer.requestBody, _ownerRequest().toJson());
      expect(secureStorageHelper.accessToken, 'access-token');
      expect(secureStorageHelper.refreshToken, 'refresh-token');
      expect(secureStorageHelper.userType, 'OWNER');
      expect(
        response
            .fold((failure) => fail(failure.message), (value) => value)
            .data
            .user
            .id,
        'user-id',
      );
    },
  );

  test('login sends only email and password and saves auth session', () async {
    final apiConsumer = _FakeApiConsumer(_loginResponse());
    final secureStorageHelper = _FakeSecureStorageHelper();
    final repository = AuthRepositoryImpl(
      apiConsumer: apiConsumer,
      secureStorageHelper: secureStorageHelper,
    );

    final result = await repository.login(
      const LoginRequestModel(
        email: 'student@example.com',
        password: 'private-password',
      ),
    );

    expect(apiConsumer.requestPath, 'auth/login');
    expect(apiConsumer.requestBody, {
      'email': 'student@example.com',
      'password': 'private-password',
    });
    expect(secureStorageHelper.accessToken, 'access-token');
    expect(secureStorageHelper.refreshToken, 'refresh-token');
    expect(secureStorageHelper.userType, 'STUDENT');
    expect(
      result
          .fold((failure) => fail(failure.message), (value) => value)
          .data
          .user
          .role,
      'STUDENT',
    );
  });

  test('login request model serializes exactly the API fields', () {
    const request = LoginRequestModel(
      email: 'owner@example.com',
      password: 'private-password',
    );

    expect(request.toJson(), {
      'email': 'owner@example.com',
      'password': 'private-password',
    });
    expect(
      request,
      const LoginRequestModel(
        email: 'owner@example.com',
        password: 'private-password',
      ),
    );
  });

  test('login response parses nullable gender and governorate', () {
    final response = RegistrationResponseModel.fromJson(_loginResponse());

    expect(response.code, 'AUTH_LOGIN_SUCCESS');
    expect(response.data.user.gender, isNull);
    expect(response.data.user.governorate, isNull);
    expect(response.data.user.university, isNull);
  });

  test('repository maps AppException to a typed failure', () async {
    final repository = AuthRepositoryImpl(
      apiConsumer: _FakeApiConsumer(
        null,
        exception: NetworkException('No internet connection.'),
      ),
      secureStorageHelper: _FakeSecureStorageHelper(),
    );

    final result = await repository.registerOwner(_ownerRequest());

    expect(
      result.fold((failure) => failure, (_) => null),
      isA<NetworkFailure>(),
    );
  });

  test(
    'repository rejects unsuccessful responses instead of returning success',
    () async {
      final unsuccessfulResponse = _successResponse()
        ..['success'] = false
        ..['code'] = 'REGISTRATION_REJECTED';
      final secureStorageHelper = _FakeSecureStorageHelper();
      final repository = AuthRepositoryImpl(
        apiConsumer: _FakeApiConsumer(unsuccessfulResponse),
        secureStorageHelper: secureStorageHelper,
      );

      final result = await repository.registerOwner(_ownerRequest());

      expect(result.isLeft(), isTrue);
      expect(secureStorageHelper.accessToken, isNull);
      expect(secureStorageHelper.refreshToken, isNull);
    },
  );

  test('cubit prevents overlapping submissions and emits success', () async {
    final completer = Completer<Either<Failure, RegistrationResponseModel>>();
    final repository = _ControlledAuthRepository(completer.future);
    final cubit = AuthCubit(authRepository: repository);

    final registration = cubit.registerOwner(_ownerRequest());
    expect(cubit.state, isA<AuthLoading>());

    await cubit.registerOwner(_ownerRequest());
    expect(repository.ownerRequestCount, 1);

    completer.complete(
      Right(RegistrationResponseModel.fromJson(_successResponse())),
    );
    await registration;
    expect(cubit.state, isA<AuthSuccess>());
    await cubit.close();
  });

  test('cubit maps connection failures to a user-safe error', () async {
    final cubit = AuthCubit(authRepository: _FailingAuthRepository());

    await cubit.registerOwner(_ownerRequest());

    expect(cubit.state, isA<AuthFailureState>());
    expect(
      (cubit.state as AuthFailureState).message,
      contains('تعذر الاتصال بالإنترنت'),
    );
    await cubit.close();
  });

  test(
    'login cubit prevents duplicate requests and exposes user role',
    () async {
      final completer = Completer<Either<Failure, RegistrationResponseModel>>();
      final repository = _ControlledAuthRepository(completer.future);
      final cubit = AuthCubit(authRepository: repository);
      const request = LoginRequestModel(
        email: 'student@example.com',
        password: 'private-password',
      );

      final login = cubit.login(request);
      expect(cubit.state, isA<AuthLoading>());
      await cubit.login(request);
      expect(repository.loginRequestCount, 1);

      completer.complete(
        Right(RegistrationResponseModel.fromJson(_loginResponse())),
      );
      await login;
      expect(cubit.state, isA<AuthSuccess>());
      expect((cubit.state as AuthSuccess).response.data.user.role, 'STUDENT');
      await cubit.close();
    },
  );

  test('login cubit returns a safe invalid-credentials message', () async {
    final cubit = AuthCubit(authRepository: _InvalidCredentialsRepository());

    await cubit.login(
      const LoginRequestModel(
        email: 'student@example.com',
        password: 'incorrect-password',
      ),
    );

    expect(cubit.state, isA<AuthFailureState>());
    expect((cubit.state as AuthFailureState).message, contains('غير صحيحة'));
    await cubit.close();
  });

  test('auth states model initial, loading, success, and failure', () {
    const initialState = AuthInitial();
    const loadingState = AuthLoading();
    final successState = AuthSuccess(
      RegistrationResponseModel.fromJson(_loginResponse()),
    );
    const failureState = AuthFailureState('تعذر تسجيل الدخول');

    expect(initialState, isA<AuthStates>());
    expect(loadingState, isA<Equatable>());
    expect(successState, isA<AuthSuccess>());
    expect(failureState, isA<AuthFailureState>());
    expect(failureState.message, 'تعذر تسجيل الدخول');
    expect(
      successState,
      AuthSuccess(RegistrationResponseModel.fromJson(_loginResponse())),
    );
  });

  test('auth initial state uses Equatable value equality', () {
    expect(const AuthInitial(), const AuthInitial());
    expect(const AuthInitial(), isA<Equatable>());
  });
}

OwnerRegistrationRequest _ownerRequest() {
  return const OwnerRegistrationRequest(
    fullName: 'مالك تجريبي',
    email: 'owner@example.com',
    phone: '01012345678',
    password: 'password',
    governorate: 'الجيزة',
    gender: 'MALE',
  );
}

StudentRegistrationRequest _studentRequest() {
  return const StudentRegistrationRequest(
    fullName: 'طالب تجريبي',
    email: 'student@example.com',
    phone: '01012345679',
    password: 'password',
    confirmPassword: 'password',
    gender: 'MALE',
    governorate: 'القاهرة',
    university: 'جامعة عين شمس',
    faculty: 'كلية الهندسة',
    major: 'هندسة مدنية',
    academicYear: 'الفرقة الأولى',
  );
}

Map<String, dynamic> _successResponse() {
  return {
    'success': true,
    'code': 'AUTH_ACCOUNT_CREATED',
    'message': 'Account created',
    'data': {
      'accessToken': 'access-token',
      'refreshToken': 'refresh-token',
      'user': {
        'id': 'user-id',
        'fullName': 'مالك تجريبي',
        'firstName': 'مالك',
        'lastName': 'تجريبي',
        'email': 'owner@example.com',
        'phone': '01012345678',
        'role': 'OWNER',
        'profileImage': null,
        'bio': null,
        'gender': 'MALE',
        'governorate': 'الجيزة',
        'university': null,
        'faculty': null,
        'major': null,
        'academicYear': null,
        'housingStatus': null,
        'interests': ['reading', 'sports'],
        'isActive': true,
        'createdAt': '2026-10-26T00:00:00.000Z',
        'updatedAt': '2026-10-26T00:00:00.000Z',
      },
    },
  };
}

class _FakeApiConsumer implements ApiConsumer {
  _FakeApiConsumer(this.response, {this.exception});

  final dynamic response;
  final Exception? exception;
  String? requestPath;
  Object? requestBody;

  @override
  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool isFromData = false,
  }) async {
    requestPath = path;
    requestBody = data;
    final error = exception;
    if (error != null) throw error;
    return response;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSecureStorageHelper extends SecureStorageHelper {
  _FakeSecureStorageHelper() : super.internal();

  String? accessToken;
  String? refreshToken;
  String? userType;

  @override
  Future<void> saveAuthenticationTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  @override
  Future<void> saveUserType(String userType) async {
    this.userType = userType;
  }
}

class _ControlledAuthRepository implements AuthRepository {
  _ControlledAuthRepository(this.registrationResponse);

  final Future<Either<Failure, RegistrationResponseModel>> registrationResponse;
  int ownerRequestCount = 0;
  int loginRequestCount = 0;

  @override
  Future<Either<Failure, RegistrationResponseModel>> registerOwner(
    OwnerRegistrationRequest request,
  ) {
    ownerRequestCount++;
    return registrationResponse;
  }

  @override
  Future<Either<Failure, RegistrationResponseModel>> registerStudent(
    StudentRegistrationRequest request,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, RegistrationResponseModel>> login(
    LoginRequestModel request,
  ) {
    loginRequestCount++;
    return registrationResponse;
  }
}

class _FailingAuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, RegistrationResponseModel>> registerOwner(
    OwnerRegistrationRequest request,
  ) async => const Left(NetworkFailure('Connection error'));

  @override
  Future<Either<Failure, RegistrationResponseModel>> registerStudent(
    StudentRegistrationRequest request,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, RegistrationResponseModel>> login(
    LoginRequestModel request,
  ) async => const Left(NetworkFailure('No internet connection.'));
}

class _InvalidCredentialsRepository implements AuthRepository {
  @override
  Future<Either<Failure, RegistrationResponseModel>> login(
    LoginRequestModel request,
  ) async => const Left(AuthFailure('Unauthorized'));

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

Map<String, dynamic> _loginResponse() {
  final user = Map<String, dynamic>.from(
    _successResponse()['data'] as Map<String, dynamic>,
  );
  final rawUser =
      Map<String, dynamic>.from(user['user'] as Map<String, dynamic>)
        ..['role'] = 'STUDENT'
        ..['gender'] = null
        ..['governorate'] = null
        ..['university'] = null
        ..['faculty'] = null
        ..['major'] = null
        ..['academicYear'] = null;
  user['user'] = rawUser;
  return {
    'success': true,
    'code': 'AUTH_LOGIN_SUCCESS',
    'message': 'تم تسجيل الدخول بنجاح',
    'data': user,
  };
}
