import 'package:dartz/dartz.dart';
import 'package:skann_app/core/errors/exceptions.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/core/errors/failure_mapper.dart';
import 'package:skann_app/core/network/api_consumer.dart';
import 'package:skann_app/features/home/data/models/property_page_model.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, PropertyPageModel>> getFavorites({
    required int page,
    required int limit,
  });

  Future<Either<Failure, Unit>> addFavorite({required String propertyId});

  Future<Either<Failure, Unit>> removeFavorite({required String propertyId});
}

class FavoritesRepositoryImpl implements FavoritesRepository {
  const FavoritesRepositoryImpl({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  @override
  Future<Either<Failure, PropertyPageModel>> getFavorites({
    required int page,
    required int limit,
  }) async {
    if (page < 1 || limit < 1) {
      return const Left(ValidationFailure('Invalid favorites page.'));
    }

    try {
      final response = await apiConsumer.get(
        'favorites',
        queryParameters: {'page': page, 'limit': limit},
      );
      if (response is! Map) {
        throw const FormatException('Favorites response is not an object.');
      }
      final json = Map<String, dynamic>.from(response);
      if (json['success'] == false) {
        throw const FormatException('Favorites request was unsuccessful.');
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
        UnexpectedFailure('The favorites response was invalid.'),
      );
    } on TypeError {
      return const Left(
        UnexpectedFailure('The favorites response was invalid.'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> addFavorite({required String propertyId}) =>
      _updateFavorite(propertyId, add: true);

  @override
  Future<Either<Failure, Unit>> removeFavorite({required String propertyId}) =>
      _updateFavorite(propertyId, add: false);

  Future<Either<Failure, Unit>> _updateFavorite(
    String propertyId, {
    required bool add,
  }) async {
    final normalizedId = propertyId.trim();
    if (normalizedId.isEmpty) {
      return const Left(ValidationFailure('Property selection is incomplete.'));
    }

    try {
      final path = 'favorites/${Uri.encodeComponent(normalizedId)}';
      final response = add
          ? await apiConsumer.post(path)
          : await apiConsumer.delete(path);
      if (response is Map && response['success'] == false) {
        return const Left(
          UnexpectedFailure('The favorite request was unsuccessful.'),
        );
      }
      return const Right(unit);
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    }
  }
}
