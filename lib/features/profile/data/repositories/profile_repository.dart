import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skann_app/core/errors/exceptions.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/core/errors/failure_mapper.dart';
import 'package:skann_app/core/network/api_constants.dart';
import 'package:skann_app/core/network/api_consumer.dart';
import 'package:skann_app/features/auth/data/models/registration_response_model.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserModel>> getMyProfile();
  Future<Either<Failure, UserModel>> updateProfile(
    Map<String, Object?> changes, {
    XFile? profileImage,
  });
  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<Either<Failure, Unit>> logout({required String refreshToken});
}

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  @override
  Future<Either<Failure, UserModel>> getMyProfile() async {
    try {
      final response = await apiConsumer.get(EndPoint.myProfile);
      if (response is! Map) {
        throw const FormatException('Profile response is not an object.');
      }

      final json = Map<String, dynamic>.from(response);
      if (json['success'] == false) {
        throw const FormatException('Profile request was unsuccessful.');
      }

      final rawData = json['data'];
      if (rawData is! Map) {
        throw const FormatException('Profile response data is missing.');
      }

      return Right(
        UserModel.fromProfileJson(Map<String, dynamic>.from(rawData)),
      );
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } on PlatformException {
      return const Left(
        StorageFailure('Could not access the authenticated profile.'),
      );
    } on FormatException {
      return const Left(UnexpectedFailure('The profile response was invalid.'));
    } on TypeError {
      return const Left(UnexpectedFailure('The profile response was invalid.'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> updateProfile(
    Map<String, Object?> changes, {
    XFile? profileImage,
  }) async {
    try {
      if (changes.isEmpty && profileImage == null) {
        return const Left(
          ValidationFailure(' لم يتم إجراء أي تغييرات على البيانات.'),
        );
      }

      Object requestBody = changes;
      if (profileImage != null) {
        final formFields = Map<String, dynamic>.from(changes);
        formFields['profileImage'] = MultipartFile.fromBytes(
          await profileImage.readAsBytes(),
          filename: profileImage.name.trim().isEmpty
              ? 'profile_image.jpg'
              : profileImage.name,
        );
        requestBody = FormData.fromMap(formFields);
      }

      final response = await apiConsumer.patch(
        EndPoint.myProfile,
        data: requestBody,
      );
      if (response is! Map) {
        throw const FormatException('Profile response is not an object.');
      }

      final json = Map<String, dynamic>.from(response);
      if (json['success'] != true) {
        final message = json['message'];
        return Left(
          ServerFailure(
            message is String && message.trim().isNotEmpty
                ? message
                : 'The profile could not be updated.',
            code: json['code'] is String ? json['code'] as String : null,
          ),
        );
      }

      final rawData = json['data'];
      if (rawData is! Map) {
        throw const FormatException('Profile response data is missing.');
      }

      final profileData = Map<String, dynamic>.from(rawData);
      if (!_containsRequestedUpdates(profileData, changes)) {
        return const Left(
          ServerFailure(
            'لم يؤكد الخادم حفظ التعديلات. أعد المحاولة، وإذا استمرت المشكلة تواصل مع الدعم.',
            code: 'PROFILE_UPDATE_NOT_APPLIED',
          ),
        );
      }

      return Right(UserModel.fromProfileJson(profileData));
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } on PlatformException {
      return const Left(
        StorageFailure('Could not access the authenticated profile.'),
      );
    } on FormatException {
      return const Left(UnexpectedFailure('The profile response was invalid.'));
    } on TypeError {
      return const Left(UnexpectedFailure('The profile response was invalid.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await apiConsumer.patch(
        EndPoint.myPassword,
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );
      if (response is! Map) {
        throw const FormatException(
          'Password change response is not an object.',
        );
      }

      final json = Map<String, dynamic>.from(response);
      if (json['success'] != true) {
        final message = json['message'];
        return Left(
          ServerFailure(
            message is String && message.trim().isNotEmpty
                ? message
                : 'The password could not be changed.',
            code: json['code'] is String ? json['code'] as String : null,
          ),
        );
      }

      if (json['code'] != 'USER_PASSWORD_UPDATED') {
        return const Left(
          UnexpectedFailure('The password change response was invalid.'),
        );
      }

      return const Right(unit);
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } on FormatException {
      return const Left(
        UnexpectedFailure('The password change response was invalid.'),
      );
    } on TypeError {
      return const Left(
        UnexpectedFailure('The password change response was invalid.'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> logout({required String refreshToken}) async {
    try {
      final response = await apiConsumer.post(
        EndPoint.logout,
        data: {'refreshToken': refreshToken},
      );
      if (response is! Map) {
        throw const FormatException('Logout response is not an object.');
      }

      final json = Map<String, dynamic>.from(response);
      if (json['success'] != true) {
        final message = json['message'];
        return Left(
          ServerFailure(
            message is String && message.trim().isNotEmpty
                ? message
                : 'تعذر تسجيل الخروج. حاول مرة أخرى.',
            code: json['code'] is String ? json['code'] as String : null,
          ),
        );
      }
      if (json['code'] != 'AUTH_LOGOUT_SUCCESS') {
        return const Left(UnexpectedFailure('استجابة تسجيل الخروج غير صالحة.'));
      }

      return const Right(unit);
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } on FormatException {
      return const Left(UnexpectedFailure('استجابة تسجيل الخروج غير صالحة.'));
    } on TypeError {
      return const Left(UnexpectedFailure('استجابة تسجيل الخروج غير صالحة.'));
    }
  }

  bool _containsRequestedUpdates(
    Map<String, dynamic> profileData,
    Map<String, Object?> changes,
  ) {
    for (final entry in changes.entries) {
      if (!profileData.containsKey(entry.key)) return false;
      final actual = profileData[entry.key];
      final expected = entry.value;
      if (expected is String && actual is String) {
        if (actual.trim() != expected.trim()) return false;
      } else if (expected is List && actual is List) {
        if (expected.length != actual.length) return false;
        for (var index = 0; index < expected.length; index++) {
          if (expected[index] != actual[index]) return false;
        }
      } else if (actual != expected) {
        return false;
      }
    }

    return true;
  }
}
