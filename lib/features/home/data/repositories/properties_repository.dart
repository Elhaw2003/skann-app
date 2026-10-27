import 'package:dartz/dartz.dart';
import 'package:skann_app/core/errors/exceptions.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/core/errors/failure_mapper.dart';
import 'package:skann_app/core/network/api_constants.dart';
import 'package:skann_app/core/network/api_consumer.dart';
import 'package:skann_app/features/home/data/models/property_filters.dart';
import 'package:skann_app/features/home/data/models/property_page_model.dart';

abstract class PropertiesRepository {
  Future<Either<Failure, PropertyPageModel>> fetchProperties({
    required int page,
    required int limit,
    required PropertyFilters filters,
    String? search,
  });
}

class PropertiesRepositoryImpl implements PropertiesRepository {
  const PropertiesRepositoryImpl({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  @override
  Future<Either<Failure, PropertyPageModel>> fetchProperties({
    required int page,
    required int limit,
    required PropertyFilters filters,
    String? search,
  }) async {
    try {
      final response = await apiConsumer.get(
        EndPoint.properties,
        queryParameters: filters.toQueryParameters(
          page: page,
          limit: limit,
          search: search,
        ),
      );
      if (response is! Map) {
        throw const FormatException('Properties response is not an object.');
      }
      final json = Map<String, dynamic>.from(response);
      if (json['success'] == false) {
        throw const FormatException('Properties request was unsuccessful.');
      }
      return Right(
        PropertyPageModel.fromJson(
          json,
          fallbackPage: page,
          fallbackLimit: limit,
        ),
      );
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } on FormatException {
      return const Left(
        UnexpectedFailure('The properties response was invalid.'),
      );
    } on TypeError {
      return const Left(
        UnexpectedFailure('The properties response was invalid.'),
      );
    }
  }
}
