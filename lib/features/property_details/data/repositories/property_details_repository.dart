import 'package:dartz/dartz.dart';
import 'package:skann_app/core/errors/exceptions.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/core/errors/failure_mapper.dart';
import 'package:skann_app/core/network/api_consumer.dart';
import 'package:skann_app/features/home/data/models/property_model.dart';
import 'package:skann_app/features/property_details/data/models/record_property_view_model.dart';

abstract class PropertyDetailsRepository {
  Future<Either<Failure, PropertyModel>> getPropertyDetails(String propertyId);

  Future<Either<Failure, RecordPropertyViewModel>> recordPropertyView(
    String propertyId,
  );
}

class PropertyDetailsRepositoryImpl implements PropertyDetailsRepository {
  const PropertyDetailsRepositoryImpl({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  @override
  Future<Either<Failure, PropertyModel>> getPropertyDetails(
    String propertyId,
  ) async {
    if (propertyId.trim().isEmpty) {
      return const Left(ValidationFailure('Invalid property ID.'));
    }

    try {
      final response = await apiConsumer.get(_propertyPath(propertyId));
      final data = _responseData(response, 'Property details');
      return Right(PropertyModel.fromJson(data));
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } on FormatException {
      return const Left(
        UnexpectedFailure('The property details response was invalid.'),
      );
    } on TypeError {
      return const Left(
        UnexpectedFailure('The property details response was invalid.'),
      );
    }
  }

  @override
  Future<Either<Failure, RecordPropertyViewModel>> recordPropertyView(
    String propertyId,
  ) async {
    if (propertyId.trim().isEmpty) {
      return const Left(ValidationFailure('Invalid property ID.'));
    }

    try {
      final response = await apiConsumer.post(
        '${_propertyPath(propertyId)}/view',
      );
      final data = _responseData(response, 'Record view');
      return Right(RecordPropertyViewModel.fromJson(data));
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } on FormatException {
      return const Left(
        UnexpectedFailure('The record view response was invalid.'),
      );
    } on TypeError {
      return const Left(
        UnexpectedFailure('The record view response was invalid.'),
      );
    }
  }

  String _propertyPath(String propertyId) =>
      'properties/${Uri.encodeComponent(propertyId)}';

  Map<String, dynamic> _responseData(Object? response, String label) {
    if (response is! Map) {
      throw FormatException('$label response is not an object.');
    }
    final json = Map<String, dynamic>.from(response);
    if (json['success'] == false) {
      throw FormatException('$label request was unsuccessful.');
    }
    final rawData = json['data'];
    if (rawData is! Map) {
      throw FormatException('$label response data is missing.');
    }
    return Map<String, dynamic>.from(rawData);
  }
}
