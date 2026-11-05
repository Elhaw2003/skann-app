import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/features/booking_requests/data/models/booking_request_model.dart';
import 'package:skann_app/features/booking_requests/data/repositories/booking_requests_repo.dart';
import 'package:skann_app/features/booking_requests/presentation/cubit/booking_requests_states.dart';

class BookingRequestsCubit extends Cubit<BookingRequestsStates> {
  BookingRequestsCubit({required this.repository})
    : super(const BookingRequestsInitial());

  static const int pageSize = 10;

  final BookingRequestsRepo repository;
  int _listRequestGeneration = 0;
  int _roomCheckGeneration = 0;

  Future<void> loadRequests({
    BookingStatusFilter filter = BookingStatusFilter.all,
  }) async {
    if (isClosed) return;
    if (state is BookingRequestsLoaded) return;

    final generation = ++_listRequestGeneration;
    emit(BookingRequestsLoading(filter: filter));
    final result = await _requestPage(page: 1, filter: filter);
    if (isClosed || generation != _listRequestGeneration) return;

    result.fold(
      (failure) => emit(
        BookingRequestsError(_listErrorMessage(failure), filter: filter),
      ),
      (page) => emit(
        BookingRequestsLoaded(
          bookings: page.items,
          page: page.page,
          totalPages: page.totalPages,
          hasNextPage: page.hasNextPage,
          filter: filter,
        ),
      ),
    );
  }

  Future<void> refreshRequests() async {
    final currentState = state;
    if (isClosed) return;
    if (currentState is! BookingRequestsLoaded ||
        currentState is BookingRequestsCancelling ||
        currentState is BookingRequestsRefreshing ||
        currentState is BookingRequestsLoadingMore) {
      return;
    }

    final generation = ++_listRequestGeneration;
    emit(
      BookingRequestsRefreshing(
        bookings: currentState.bookings,
        page: currentState.page,
        totalPages: currentState.totalPages,
        hasNextPage: currentState.hasNextPage,
        filter: currentState.filter,
      ),
    );
    final result = await _requestPage(page: 1, filter: currentState.filter);
    if (isClosed || generation != _listRequestGeneration) return;

    result.fold(
      (failure) => emit(
        BookingRequestsLoaded(
          bookings: currentState.bookings,
          page: currentState.page,
          totalPages: currentState.totalPages,
          hasNextPage: currentState.hasNextPage,
          filter: currentState.filter,
          refreshError: _listErrorMessage(failure),
        ),
      ),
      (page) => emit(
        BookingRequestsLoaded(
          bookings: page.items,
          page: page.page,
          totalPages: page.totalPages,
          hasNextPage: page.hasNextPage,
          filter: currentState.filter,
        ),
      ),
    );
  }

  Future<void> loadMoreRequests() async {
    final currentState = state;
    if (isClosed ||
        currentState is! BookingRequestsLoaded ||
        currentState is BookingRequestsCancelling ||
        currentState is BookingRequestsLoadingMore ||
        currentState is BookingRequestsRefreshing ||
        !currentState.hasNextPage) {
      return;
    }

    final requestedPage = currentState.page + 1;
    if (requestedPage > currentState.totalPages) return;
    final generation = _listRequestGeneration;
    emit(
      BookingRequestsLoadingMore(
        bookings: currentState.bookings,
        page: currentState.page,
        totalPages: currentState.totalPages,
        hasNextPage: currentState.hasNextPage,
        filter: currentState.filter,
      ),
    );
    final result = await _requestPage(
      page: requestedPage,
      filter: currentState.filter,
    );
    if (isClosed || generation != _listRequestGeneration) return;

    result.fold(
      (failure) => emit(
        BookingRequestsLoaded(
          bookings: currentState.bookings,
          page: currentState.page,
          totalPages: currentState.totalPages,
          hasNextPage: currentState.hasNextPage,
          filter: currentState.filter,
          loadMoreError: _listErrorMessage(failure),
        ),
      ),
      (page) => emit(
        BookingRequestsLoaded(
          bookings: _appendUnique(currentState.bookings, page.items),
          page: page.page,
          totalPages: page.totalPages,
          hasNextPage: page.hasNextPage,
          filter: currentState.filter,
        ),
      ),
    );
  }

  Future<void> filterRequests(BookingStatusFilter filter) async {
    if (isClosed) return;
    final currentState = state;
    if (currentState is BookingRequestsCancelling) return;
    if (currentState is BookingRequestsLoaded &&
        currentState.filter == filter) {
      return;
    }
    if (currentState is BookingRequestsLoading &&
        currentState.filter == filter) {
      return;
    }

    final generation = ++_listRequestGeneration;
    emit(BookingRequestsLoading(filter: filter));
    final result = await _requestPage(page: 1, filter: filter);
    if (isClosed || generation != _listRequestGeneration) return;

    result.fold(
      (failure) => emit(
        BookingRequestsError(_listErrorMessage(failure), filter: filter),
      ),
      (page) => emit(
        BookingRequestsLoaded(
          bookings: page.items,
          page: page.page,
          totalPages: page.totalPages,
          hasNextPage: page.hasNextPage,
          filter: filter,
        ),
      ),
    );
  }

  Future<void> checkRoomBooking({
    required String propertyId,
    required String roomId,
    bool force = false,
  }) async {
    if (isClosed) return;
    if (state is BookingRoomCheckLoading) return;
    final currentState = state;
    if (!force &&
        currentState is BookingRoomAvailable &&
        currentState.propertyId == propertyId &&
        currentState.roomId == roomId) {
      return;
    }
    if (!force &&
        currentState is BookingRoomAlreadyRequested &&
        _matchesRoom(currentState.booking, propertyId, roomId)) {
      return;
    }

    if (propertyId.trim().isEmpty || roomId.trim().isEmpty) {
      emit(
        BookingRoomCheckError(
          propertyId: propertyId,
          roomId: roomId,
          message: 'تعذر التحقق من طلبات الحجز لهذه الغرفة.',
        ),
      );
      return;
    }

    final generation = ++_roomCheckGeneration;
    emit(BookingRoomCheckLoading(propertyId, roomId));

    var pageNumber = 1;
    while (true) {
      final result = await repository.getMyBookingRequests(
        page: pageNumber,
        limit: pageSize,
      );
      if (isClosed || generation != _roomCheckGeneration) return;

      final page = result.fold<BookingRequestsPage?>((failure) {
        emit(
          BookingRoomCheckError(
            propertyId: propertyId,
            roomId: roomId,
            message: _roomCheckErrorMessage(failure),
          ),
        );
        return null;
      }, (page) => page);
      if (page == null) return;

      for (final booking in page.items) {
        if (_matchesRoom(booking, propertyId, roomId)) {
          emit(BookingRoomAlreadyRequested(booking));
          return;
        }
      }

      if (!page.hasNextPage || page.page >= page.totalPages) {
        emit(BookingRoomAvailable(propertyId, roomId));
        return;
      }

      final nextPage = page.page + 1;
      if (nextPage <= pageNumber) {
        emit(
          BookingRoomCheckError(
            propertyId: propertyId,
            roomId: roomId,
            message: 'تعذر التحقق من طلبات الحجز لهذه الغرفة.',
          ),
        );
        return;
      }
      pageNumber = nextPage;
    }
  }

  Future<void> createBookingRequest({
    required String propertyId,
    required String roomId,
    required String message,
  }) async {
    if (isClosed || state is BookingRequestSubmitting) return;
    if (propertyId.trim().isEmpty || roomId.trim().isEmpty) {
      emit(
        BookingRequestSubmissionError(
          message: 'تعذر تحديد السكن أو الغرفة.',
          submittedMessage: message,
        ),
      );
      return;
    }

    emit(BookingRequestSubmitting(message));
    final result = await repository.createBookingRequest(
      propertyId: propertyId,
      roomId: roomId,
      message: message,
    );
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        BookingRequestSubmissionError(
          message: _submissionErrorMessage(failure),
          submittedMessage: message,
        ),
      ),
      (booking) => emit(BookingCreatedSuccessfully(booking)),
    );
  }

  Future<void> cancelBookingRequest(BookingRequestModel booking) async {
    final currentState = state;
    if (isClosed ||
        currentState is! BookingRequestsLoaded ||
        currentState is BookingRequestsCancelling ||
        currentState is BookingRequestsRefreshing ||
        currentState is BookingRequestsLoadingMore ||
        booking.status != 'PENDING') {
      return;
    }

    final bookingId = booking.id;
    if (bookingId == null || bookingId.trim().isEmpty) return;

    final currentBooking = currentState.bookings
        .where((candidate) => candidate.id == bookingId)
        .firstOrNull;
    if (currentBooking == null || currentBooking.status != 'PENDING') return;

    emit(
      BookingRequestsCancelling(
        bookings: currentState.bookings,
        page: currentState.page,
        totalPages: currentState.totalPages,
        hasNextPage: currentState.hasNextPage,
        filter: currentState.filter,
        bookingId: bookingId,
      ),
    );

    final result = await repository.cancelBookingRequest(bookingId: bookingId);
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        BookingRequestsLoaded(
          bookings: currentState.bookings,
          page: currentState.page,
          totalPages: currentState.totalPages,
          hasNextPage: currentState.hasNextPage,
          filter: currentState.filter,
          cancellationError: _cancellationErrorMessage(failure),
        ),
      ),
      (_) {
        emit(
          BookingRequestsLoaded(
            bookings: List.unmodifiable(
              currentState.bookings.map(
                (item) => item.id == bookingId
                    ? item.copyWith(status: 'CANCELLED')
                    : item,
              ),
            ),
            page: currentState.page,
            totalPages: currentState.totalPages,
            hasNextPage: currentState.hasNextPage,
            filter: currentState.filter,
          ),
        );
      },
    );

    if (result.isRight()) await refreshRequests();
  }

  Future<Either<Failure, BookingRequestsPage>> _requestPage({
    required int page,
    required BookingStatusFilter filter,
  }) {
    return repository.getMyBookingRequests(
      page: page,
      limit: pageSize,
      status: filter.apiValue,
    );
  }

  List<BookingRequestModel> _appendUnique(
    List<BookingRequestModel> current,
    List<BookingRequestModel> nextPage,
  ) {
    final knownIds = current
        .map((booking) => booking.id)
        .whereType<String>()
        .toSet();
    final combined = [...current];
    for (final booking in nextPage) {
      final id = booking.id;
      if (id == null || knownIds.add(id)) combined.add(booking);
    }
    return List.unmodifiable(combined);
  }

  bool _matchesRoom(
    BookingRequestModel booking,
    String propertyId,
    String roomId,
  ) {
    final requestedPropertyId = booking.propertyId ?? booking.property?.id;
    final requestedRoomId = booking.roomId ?? booking.room?.id;
    return requestedPropertyId == propertyId && requestedRoomId == roomId;
  }

  String _submissionErrorMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'تعذر الاتصال بالإنترنت. تحقق من اتصالك وحاول مرة أخرى.';
    }
    if (failure is AuthFailure) {
      return 'انتهت صلاحية تسجيل الدخول. سجّل الدخول ثم حاول مرة أخرى.';
    }
    if (failure is ValidationFailure) {
      return 'تعذر إرسال الطلب. راجع البيانات وحاول مرة أخرى.';
    }
    if (failure is NotFoundFailure) {
      return 'لم تعد الغرفة أو الوحدة السكنية متاحة.';
    }
    if (failure is PermissionFailure) {
      return 'لا تملك صلاحية إرسال طلب حجز.';
    }
    return 'لم نتمكن من إرسال الطلب. حاول مرة أخرى.';
  }

  String _cancellationErrorMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'تعذر الاتصال بالإنترنت. تحقق من اتصالك وحاول مرة أخرى.';
    }
    if (failure is AuthFailure) {
      return 'انتهت صلاحية تسجيل الدخول. سجّل الدخول ثم حاول مرة أخرى.';
    }
    if (failure is PermissionFailure) {
      return 'لا تملك صلاحية إلغاء طلب الحجز.';
    }
    return 'لم نتمكن من إلغاء طلب الحجز. حاول مرة أخرى.';
  }

  String _listErrorMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'تعذر الاتصال بالإنترنت. تحقق من اتصالك وحاول مرة أخرى.';
    }
    if (failure is AuthFailure) {
      return 'انتهت صلاحية تسجيل الدخول. سجّل الدخول ثم حاول مرة أخرى.';
    }
    if (failure is PermissionFailure) {
      return 'لا تملك صلاحية عرض طلبات الحجز.';
    }
    return 'لم نتمكن من تحميل طلبات الحجز. حاول مرة أخرى.';
  }

  String _roomCheckErrorMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'تعذر الاتصال بالإنترنت للتحقق من طلبات الحجز.';
    }
    if (failure is AuthFailure) {
      return 'انتهت صلاحية تسجيل الدخول. سجّل الدخول ثم حاول مرة أخرى.';
    }
    return 'تعذر التحقق من وجود طلب حجز سابق. حاول مرة أخرى.';
  }
}
