import 'package:dartz/dartz.dart';
import 'package:skann_app/core/errors/exceptions.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/core/errors/failure_mapper.dart';
import 'package:skann_app/core/network/api_constants.dart';
import 'package:skann_app/core/network/api_consumer.dart';
import 'package:skann_app/features/matching_roommates/data/models/matching_roommates_page_model.dart';

abstract class MatchingRoommatesRepository {
  Future<Either<Failure, MatchingRoommatesPageModel>> getMatchingRoommates({
    required int page,
    required int limit,
  });

  Future<Either<Failure, MatchingRoommatesPageModel>> getRoommatesDirectory({
    required int page,
    required int limit,
    String? governorate,
    String? university,
    String? faculty,
  });
}

class MatchingRoommatesRepositoryImpl implements MatchingRoommatesRepository {
  const MatchingRoommatesRepositoryImpl({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  @override
  Future<Either<Failure, MatchingRoommatesPageModel>> getMatchingRoommates({
    required int page,
    required int limit,
  }) async {
    return _getRoommates(
      page: page,
      limit: limit,
      queryParameters: {'matchMyProfile': true, 'page': page, 'limit': limit},
    );
  }

  @override
  Future<Either<Failure, MatchingRoommatesPageModel>> getRoommatesDirectory({
    required int page,
    required int limit,
    String? governorate,
    String? university,
    String? faculty,
  }) async {
    final queryParameters = <String, dynamic>{'page': page, 'limit': limit};
    _addTextParameter(queryParameters, 'governorate', governorate);
    _addTextParameter(queryParameters, 'university', university);
    _addTextParameter(queryParameters, 'faculty', faculty);
    return _getRoommates(
      page: page,
      limit: limit,
      queryParameters: queryParameters,
    );
  }

  Future<Either<Failure, MatchingRoommatesPageModel>> _getRoommates({
    required int page,
    required int limit,
    required Map<String, dynamic> queryParameters,
  }) async {
    try {
      final response = await apiConsumer.get(
        EndPoint.roommates,
        queryParameters: queryParameters,
      );
      if (response is! Map) {
        throw const FormatException('Roommates response is not an object.');
      }

      final json = Map<String, dynamic>.from(response);
      if (json['success'] != true) {
        final message = json['message'];
        final code = json['code'];
        return Left(
          ServerFailure(
            message is String && message.trim().isNotEmpty
                ? message
                : 'Could not load matching roommates.',
            code: code is String ? code : null,
          ),
        );
      }

      return Right(
        MatchingRoommatesPageModel.fromJson(
          json,
          fallbackPage: page,
          fallbackLimit: limit,
        ),
      );
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } on FormatException {
      return const Left(
        UnexpectedFailure('The roommates response was invalid.'),
      );
    } on TypeError {
      return const Left(
        UnexpectedFailure('The roommates response was invalid.'),
      );
    }
  }

  void _addTextParameter(
    Map<String, dynamic> parameters,
    String name,
    String? value,
  ) {
    final normalized = value?.trim();
    if (normalized != null && normalized.isNotEmpty) {
      parameters[name] = normalized;
    }
  }
}
