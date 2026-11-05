import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/core/network/api_consumer.dart';
import 'package:skann_app/features/booking_requests/data/models/booking_request_model.dart';
import 'package:skann_app/features/booking_requests/data/repositories/booking_requests_repo.dart';
import 'package:skann_app/features/booking_requests/presentation/cubit/booking_requests_cubit.dart';
import 'package:skann_app/features/booking_requests/presentation/cubit/booking_requests_states.dart';
import 'package:skann_app/features/booking_requests/presentation/views/widgets/booking_request_card.dart';

void main() {
  group('BookingRequestsRepo', () {
    test(
      'loads and maps a page using the requested filter and pagination',
      () async {
        final api = _FakeApiConsumer(_bookingListResponse());
        final repository = BookingRequestsRepoImpl(apiConsumer: api);

        final result = await repository.getMyBookingRequests(
          page: 2,
          limit: 10,
          status: 'PENDING',
        );

        expect(api.getPath, 'booking-requests/my');
        expect(api.queryParameters, {
          'page': 2,
          'limit': 10,
          'status': 'PENDING',
        });
        result.fold((failure) => fail(failure.message), (page) {
          expect(page.page, 1);
          expect(page.totalPages, 3);
          expect(page.hasNextPage, isTrue);
          expect(page.items.single.property, isNotNull);
          expect(page.items.single.property?.thumbnail, 'property.jpg');
          expect(page.items.single.room?.id, 'room-1');
        });
      },
    );

    test(
      'does not send a student ID when creating a booking request',
      () async {
        final api = _FakeApiConsumer({
          'success': true,
          'data': {
            'id': 'booking-1',
            'propertyId': 'property-1',
            'roomId': 'room-1',
            'message': '',
            'status': 'PENDING',
          },
        });
        final repository = BookingRequestsRepoImpl(apiConsumer: api);

        final result = await repository.createBookingRequest(
          propertyId: 'property-1',
          roomId: 'room-1',
          message: '',
        );

        expect(api.postPath, 'booking-requests');
        expect(api.postData, {
          'propertyId': 'property-1',
          'roomId': 'room-1',
          'message': '',
        });
        expect(result.isRight(), isTrue);
      },
    );

    test('cancels without sending a body or query parameters', () async {
      final api = _FakeApiConsumer({'success': true});
      final repository = BookingRequestsRepoImpl(apiConsumer: api);

      final result = await repository.cancelBookingRequest(
        bookingId: 'booking-1',
      );

      expect(api.patchPath, 'booking-requests/booking-1/cancel');
      expect(api.patchData, isNull);
      expect(api.patchQueryParameters, isNull);
      expect(result.isRight(), isTrue);
    });

    test('fails if required pagination values are missing', () async {
      final api = _FakeApiConsumer({
        'success': true,
        'data': {
          'items': <Object>[],
          'pagination': {'page': 1},
        },
      });
      final repository = BookingRequestsRepoImpl(apiConsumer: api);

      final result = await repository.getMyBookingRequests(page: 1, limit: 10);

      expect(result.isLeft(), isTrue);
    });
  });

  test('checks every page before marking a room available', () async {
    final repository = _FakeBookingRequestsRepo({
      1: (
        items: const [
          BookingRequestModel(
            id: 'other-room',
            propertyId: 'property-1',
            roomId: 'room-2',
          ),
        ],
        page: 1,
        totalPages: 2,
        hasNextPage: true,
      ),
      2: (
        items: const [
          BookingRequestModel(
            id: 'existing-request',
            propertyId: 'property-1',
            roomId: 'room-1',
            status: 'REJECTED',
          ),
        ],
        page: 2,
        totalPages: 2,
        hasNextPage: false,
      ),
    });
    final cubit = BookingRequestsCubit(repository: repository);

    await cubit.checkRoomBooking(propertyId: 'property-1', roomId: 'room-1');

    expect(repository.requestedPages, [1, 2]);
    expect(cubit.state, isA<BookingRoomAlreadyRequested>());
    await cubit.close();
  });

  test('cancels pending bookings and refreshes the current list', () async {
    final booking = const BookingRequestModel(
      id: 'booking-1',
      status: 'PENDING',
    );
    final repository = _FakeBookingRequestsRepo({
      1: (items: [booking], page: 1, totalPages: 1, hasNextPage: false),
    });
    final cubit = BookingRequestsCubit(repository: repository);
    await cubit.loadRequests();

    await cubit.cancelBookingRequest(booking);

    expect(repository.cancelledBookingIds, ['booking-1']);
    expect(repository.requestedPages, [1, 1]);
    final loaded = cubit.state as BookingRequestsLoaded;
    expect(loaded.bookings.single.status, 'CANCELLED');
    await cubit.close();
  });

  test(
    'does not cancel a booking unless its current status is pending',
    () async {
      final rejectedBooking = const BookingRequestModel(
        id: 'booking-1',
        status: 'REJECTED',
      );
      final repository = _FakeBookingRequestsRepo({
        1: (
          items: [rejectedBooking],
          page: 1,
          totalPages: 1,
          hasNextPage: false,
        ),
      });
      final cubit = BookingRequestsCubit(repository: repository);
      await cubit.loadRequests();

      await cubit.cancelBookingRequest(rejectedBooking);

      expect(repository.cancelledBookingIds, isEmpty);
      expect(
        (cubit.state as BookingRequestsLoaded).bookings.single.status,
        'REJECTED',
      );
      await cubit.close();
    },
  );

  testWidgets('shows cancel action only for pending bookings', (tester) async {
    for (final (status, shouldShow) in [
      ('PENDING', true),
      ('APPROVED', false),
      ('REJECTED', false),
      ('CANCELLED', false),
    ]) {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: BookingRequestCard(
                booking: BookingRequestModel(id: 'booking-1', status: status),
                onTap: () {},
                onCancel: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('إلغاء طلب الحجز'), findsNWidgets(shouldShow ? 1 : 0));
    }
  });
}

Map<String, dynamic> _bookingListResponse() => {
  'success': true,
  'data': {
    'items': [
      {
        'id': 'booking-1',
        'status': 'PENDING',
        'property': {
          'id': 'property-1',
          'title': 'سكن الطلاب',
          'thumbnail': 'property.jpg',
        },
        'room': {'id': 'room-1', 'name': 'غرفة فردية'},
      },
    ],
    'pagination': {'page': 1, 'totalPages': 3, 'hasNextPage': true},
  },
};

class _FakeApiConsumer extends ApiConsumer {
  _FakeApiConsumer(this.response);

  final Object? response;
  String? getPath;
  String? postPath;
  String? patchPath;
  Map<String, dynamic>? queryParameters;
  Object? postData;
  Object? patchData;
  Map<String, dynamic>? patchQueryParameters;

  @override
  Future<dynamic> get(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    getPath = path;
    this.queryParameters = queryParameters;
    return response;
  }

  @override
  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool isFromData = false,
  }) async {
    postPath = path;
    postData = data;
    return response;
  }

  @override
  Future<dynamic> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool isFromData = false,
  }) async {
    patchPath = path;
    patchData = data;
    patchQueryParameters = queryParameters;
    return response;
  }

  @override
  Future<dynamic> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool isFromData = false,
  }) async => response;

  @override
  Future<dynamic> put(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool isFromData = false,
  }) async => response;
}

class _FakeBookingRequestsRepo implements BookingRequestsRepo {
  _FakeBookingRequestsRepo(this.pages);

  final Map<int, BookingRequestsPage> pages;
  final List<int> requestedPages = [];
  final List<String> cancelledBookingIds = [];

  @override
  Future<Either<Failure, BookingRequestsPage>> getMyBookingRequests({
    required int page,
    required int limit,
    String? status,
  }) async {
    requestedPages.add(page);
    final responsePage = pages[page];
    if (responsePage == null) {
      return const Left(UnexpectedFailure('Page missing in test fake.'));
    }
    return Right(responsePage);
  }

  @override
  Future<Either<Failure, BookingRequestModel>> createBookingRequest({
    required String propertyId,
    required String roomId,
    required String message,
  }) async {
    return const Left(UnexpectedFailure('Not used in this test.'));
  }

  @override
  Future<Either<Failure, Unit>> cancelBookingRequest({
    required String bookingId,
  }) async {
    cancelledBookingIds.add(bookingId);
    for (final entry in pages.entries.toList()) {
      pages[entry.key] = (
        items: entry.value.items
            .map(
              (booking) => booking.id == bookingId
                  ? booking.copyWith(status: 'CANCELLED')
                  : booking,
            )
            .toList(),
        page: entry.value.page,
        totalPages: entry.value.totalPages,
        hasNextPage: entry.value.hasNextPage,
      );
    }
    return const Right(unit);
  }
}
