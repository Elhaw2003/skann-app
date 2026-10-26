import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:skann_app/core/errors/exceptions.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/core/errors/failure_mapper.dart';
import 'package:skann_app/core/network/api_constants.dart';
import 'package:skann_app/core/network/api_consumer.dart';
import 'package:skann_app/core/services/secure_storage_helper.dart';
import 'package:skann_app/features/auth/data/models/owner_registration_request.dart';
import 'package:skann_app/features/auth/data/models/login_request_model.dart';
import 'package:skann_app/features/auth/data/models/registration_response_model.dart';
import 'package:skann_app/features/auth/data/models/student_registration_request.dart';

abstract class AuthRepository {
  Future<Either<Failure, RegistrationResponseModel>> registerOwner(
    OwnerRegistrationRequest request,
  );

  Future<Either<Failure, RegistrationResponseModel>> registerStudent(
    StudentRegistrationRequest request,
  );

  Future<Either<Failure, RegistrationResponseModel>> login(
    LoginRequestModel request,
  );
}

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.apiConsumer,
    required this.secureStorageHelper,
  });

  final ApiConsumer apiConsumer;
  final SecureStorageHelper secureStorageHelper;

  @override
  Future<Either<Failure, RegistrationResponseModel>> registerOwner(
    OwnerRegistrationRequest request,
  ) {
    return _authenticate(
      endpoint: EndPoint.register,
      expectedCode: 'AUTH_ACCOUNT_CREATED',
      requestBody: request.toJson(),
    );
  }

  @override
  Future<Either<Failure, RegistrationResponseModel>> registerStudent(
    StudentRegistrationRequest request,
  ) {
    return _authenticate(
      endpoint: EndPoint.register,
      expectedCode: 'AUTH_ACCOUNT_CREATED',
      requestBody: request.toJson(),
    );
  }

  @override
  Future<Either<Failure, RegistrationResponseModel>> login(
    LoginRequestModel request,
  ) {
    return _authenticate(
      endpoint: EndPoint.login,
      expectedCode: 'AUTH_LOGIN_SUCCESS',
      requestBody: request.toJson(),
    );
  }

  Future<Either<Failure, RegistrationResponseModel>> _authenticate({
    required String endpoint,
    required String expectedCode,
    required Map<String, dynamic> requestBody,
  }) async {
    try {
      final rawResponse = await apiConsumer.post(endpoint, data: requestBody);
      if (rawResponse is! Map) {
        throw const FormatException(
          'Registration response is not a JSON object.',
        );
      }

      final response = RegistrationResponseModel.fromJson(
        Map<String, dynamic>.from(rawResponse),
      );
      if (!response.success || response.code != expectedCode) {
        throw AuthException(response.message, response.code);
      }
      if (response.data.accessToken.isEmpty ||
          response.data.refreshToken.isEmpty) {
        throw const FormatException('Registration tokens are missing.');
      }

      await secureStorageHelper.saveAuthenticationTokens(
        accessToken: response.data.accessToken,
        refreshToken: response.data.refreshToken,
      );
      await secureStorageHelper.saveUserType(response.data.user.role);
      return Right(response);
    } on PlatformException {
      return const Left(StorageFailure('Could not store authentication data.'));
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } on FormatException {
      return const Left(
        UnexpectedFailure('The registration response was invalid.'),
      );
    } on TypeError {
      return const Left(
        UnexpectedFailure('The registration response was invalid.'),
      );
    }
  }
}
