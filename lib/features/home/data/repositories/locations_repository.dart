import 'package:dartz/dartz.dart';
import 'package:skann_app/core/errors/exceptions.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/core/errors/failure_mapper.dart';
import 'package:skann_app/core/network/api_constants.dart';
import 'package:skann_app/core/network/api_consumer.dart';
import 'package:skann_app/features/home/data/models/location_model.dart';

abstract class LocationsRepository {
  Future<Either<Failure, List<LocationModel>>> getLocations();
}

class LocationsRepositoryImpl implements LocationsRepository {
  LocationsRepositoryImpl({required this.apiConsumer});

  final ApiConsumer apiConsumer;
  List<LocationModel>? _cachedLocations;

  @override
  Future<Either<Failure, List<LocationModel>>> getLocations() async {
    final cachedLocations = _cachedLocations;
    if (cachedLocations != null) return Right(cachedLocations);

    try {
      final response = await apiConsumer.get(EndPoint.locations);
      if (response is! Map) {
        throw const FormatException('Locations response is not an object.');
      }
      final json = Map<String, dynamic>.from(response);
      if (json['success'] == false || json['data'] is! List) {
        throw const FormatException('Locations response was malformed.');
      }
      final locations = List<LocationModel>.unmodifiable(
        (json['data'] as List).map((value) {
          if (value is! Map) {
            throw const FormatException('Location entry is malformed.');
          }
          return LocationModel.fromJson(Map<String, dynamic>.from(value));
        }),
      );
      _cachedLocations = locations;
      return Right(locations);
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } on FormatException {
      return const Left(
        UnexpectedFailure('The locations response was invalid.'),
      );
    } on TypeError {
      return const Left(
        UnexpectedFailure('The locations response was invalid.'),
      );
    }
  }
}
