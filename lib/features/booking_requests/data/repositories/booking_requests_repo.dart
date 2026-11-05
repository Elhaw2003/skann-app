import 'package:dartz/dartz.dart';
import 'package:skann_app/core/errors/exceptions.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/core/errors/failure_mapper.dart';
import 'package:skann_app/core/network/api_consumer.dart';
import 'package:skann_app/features/booking_requests/data/models/booking_request_model.dart';

typedef BookingRequestsPage = ({
  List<BookingRequestModel> items,
  int page,
  int totalPages,
  bool hasNextPage,
});

abstract class BookingRequestsRepo {
  Future<Either<Failure, BookingRequestsPage>> getMyBookingRequests({
    required int page,
    required int limit,
    String? status,
  });

  Future<Either<Failure, BookingRequestModel>> createBookingRequest({
    required String propertyId,
    required String roomId,
    required String message,
  });

  Future<Either<Failure, Unit>> cancelBookingRequest({
    required String bookingId,
  });
}

class BookingRequestsRepoImpl implements BookingRequestsRepo {
  const BookingRequestsRepoImpl({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  @override
  Future<Either<Failure, BookingRequestsPage>> getMyBookingRequests({
    required int page,
    required int limit,
    String? status,
  }) async {
    if (page < 1 || limit < 1) {
      return const Left(ValidationFailure('Invalid booking page.'));
    }

    try {
      final response = await apiConsumer.get(
        'booking-requests/my',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status != null && status.isNotEmpty) 'status': status,
        },
      );
      final responseJson = _responseJson(response);
      final rawData = responseJson['data'];
      if (rawData is! Map) {
        throw const FormatException('Booking response data is missing.');
      }

      final data = Map<String, dynamic>.from(rawData);
      final rawItems = data['items'];
      final rawPagination = data['pagination'];
      if (rawItems is! List || rawPagination is! Map) {
        throw const FormatException('Booking response page is invalid.');
      }
      final items = rawItems
          .map((item) {
            if (item is! Map) {
              throw const FormatException('Booking list item is invalid.');
            }
            return BookingRequestModel.fromJson(
              Map<String, dynamic>.from(item),
            );
          })
          .toList(growable: false);
      final pagination = Map<String, dynamic>.from(rawPagination);
      final responsePage = _intValue(pagination['page']);
      final totalPages = _intValue(pagination['totalPages']);
      final hasNextPage = pagination['hasNextPage'];
      if (responsePage == null ||
          totalPages == null ||
          responsePage < 1 ||
          totalPages < 0 ||
          hasNextPage is! bool) {
        throw const FormatException('Booking response pagination is invalid.');
      }

      return Right((
        items: List.unmodifiable(items),
        page: responsePage,
        totalPages: totalPages,
        hasNextPage: hasNextPage,
      ));
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } on FormatException {
      return const Left(
        UnexpectedFailure('The booking requests response was invalid.'),
      );
    } on TypeError {
      return const Left(
        UnexpectedFailure('The booking requests response was invalid.'),
      );
    }
  }

  @override
  Future<Either<Failure, BookingRequestModel>> createBookingRequest({
    required String propertyId,
    required String roomId,
    required String message,
  }) async {
    if (propertyId.trim().isEmpty || roomId.trim().isEmpty) {
      return const Left(ValidationFailure('Booking selection is incomplete.'));
    }

    try {
      final response = await apiConsumer.post(
        'booking-requests',
        data: {
          'propertyId': propertyId.trim(),
          'roomId': roomId.trim(),
          'message': message,
        },
      );
      final responseJson = _responseJson(response);
      final rawData = responseJson['data'];
      if (rawData is! Map) {
        throw const FormatException('Booking response data is missing.');
      }
      return Right(
        BookingRequestModel.fromJson(Map<String, dynamic>.from(rawData)),
      );
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    } on FormatException {
      return const Left(
        UnexpectedFailure('The booking request response was invalid.'),
      );
    } on TypeError {
      return const Left(
        UnexpectedFailure('The booking request response was invalid.'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> cancelBookingRequest({
    required String bookingId,
  }) async {
    if (bookingId.trim().isEmpty) {
      return const Left(ValidationFailure('Booking selection is incomplete.'));
    }

    try {
      final response = await apiConsumer.patch(
        'booking-requests/${bookingId.trim()}/cancel',
      );
      if (response is Map && response['success'] == false) {
        return const Left(
          UnexpectedFailure('The booking request could not be cancelled.'),
        );
      }
      return const Right(unit);
    } on AppException catch (exception) {
      return Left(mapExceptionToFailure(exception));
    }
  }

  Map<String, dynamic> _responseJson(Object? response) {
    if (response is! Map) {
      throw const FormatException('Booking response is not an object.');
    }
    final json = Map<String, dynamic>.from(response);
    if (json['success'] == false) {
      throw const FormatException('Booking request was not successful.');
    }
    return json;
  }
}

int? _intValue(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
