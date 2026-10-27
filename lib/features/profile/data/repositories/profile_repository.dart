import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:skann_app/core/errors/exceptions.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/core/errors/failure_mapper.dart';
import 'package:skann_app/core/network/api_constants.dart';
import 'package:skann_app/core/network/api_consumer.dart';
import 'package:skann_app/features/auth/data/models/registration_response_model.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserModel>> getMyProfile();
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
}
