import 'package:dartz/dartz.dart';
import 'package:skann_app/core/errors/exceptions.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/core/errors/failure_mapper.dart';
import 'package:skann_app/core/network/api_constants.dart';
import 'package:skann_app/core/network/api_consumer.dart';
import 'package:skann_app/features/home/data/models/amenity_model.dart';

abstract class AmenitiesRepository {
  Future<Either<Failure, List<AmenityModel>>> getAmenities();
}

class AmenitiesRepositoryImpl implements AmenitiesRepository {
  AmenitiesRepositoryImpl({required this.apiConsumer});

  final ApiConsumer apiConsumer;
  List<AmenityModel>? _cachedAmenities;

  @override
  Future<Either<Failure, List<AmenityModel>>> getAmenities() async {
    final cachedAmenities = _cachedAmenities;
    if (cachedAmenities != null) return Right(cachedAmenities);

    try {
      final response = await apiConsumer.get(EndPoint.amenities);
      if (response is! Map) {
        throw const FormatException('Amenities response is not an object.');
      }
      final json = Map<String, dynamic>.from(response);
      if (json['success'] == false || json['data'] is! List) {
        throw const FormatException('Amenities response was malformed.');
      }
      final amenities = List<AmenityModel>.unmodifiable(
        (json['data'] as List).map((value) {
          if (value is! Map) {
            throw const FormatException('Amenity entry is malformed.');
          }
          return AmenityModel.fromJson(Map<String, dynamic>.from(value));
        }),
      );
      _cachedAmenities = amenities;
      return Right(amenities);
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } on FormatException {
      return const Left(
        UnexpectedFailure('The amenities response was invalid.'),
      );
    } on TypeError {
      return const Left(
        UnexpectedFailure('The amenities response was invalid.'),
      );
    }
  }
}
