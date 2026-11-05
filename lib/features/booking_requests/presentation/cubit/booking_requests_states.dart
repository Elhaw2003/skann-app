import 'package:equatable/equatable.dart';
import 'package:skann_app/features/booking_requests/data/models/booking_request_model.dart';

enum BookingStatusFilter {
  all(null, 'الكل'),
  pending('PENDING', 'قيد المراجعة'),
  approved('APPROVED', 'مقبول'),
  rejected('REJECTED', 'مرفوض');

  const BookingStatusFilter(this.apiValue, this.label);

  final String? apiValue;
  final String label;
}

sealed class BookingRequestsStates extends Equatable {
  const BookingRequestsStates();
}

class BookingRequestsInitial extends BookingRequestsStates {
  const BookingRequestsInitial();

  @override
  List<Object?> get props => [];
}

class BookingRequestsLoading extends BookingRequestsStates {
  const BookingRequestsLoading({this.filter = BookingStatusFilter.all});

  final BookingStatusFilter filter;

  @override
  List<Object?> get props => [filter];
}

class BookingRequestsLoaded extends BookingRequestsStates {
  const BookingRequestsLoaded({
    required this.bookings,
    required this.page,
    required this.totalPages,
    required this.hasNextPage,
    this.filter = BookingStatusFilter.all,
    this.refreshError,
    this.loadMoreError,
    this.cancellationError,
  });

  final List<BookingRequestModel> bookings;
  final int page;
  final int totalPages;
  final bool hasNextPage;
  final BookingStatusFilter filter;
  final String? refreshError;
  final String? loadMoreError;
  final String? cancellationError;

  @override
  List<Object?> get props => [
    bookings,
    page,
    totalPages,
    hasNextPage,
    filter,
    refreshError,
    loadMoreError,
    cancellationError,
  ];
}

class BookingRequestsLoadingMore extends BookingRequestsLoaded {
  const BookingRequestsLoadingMore({
    required super.bookings,
    required super.page,
    required super.totalPages,
    required super.hasNextPage,
    super.filter,
  });
}

class BookingRequestsRefreshing extends BookingRequestsLoaded {
  const BookingRequestsRefreshing({
    required super.bookings,
    required super.page,
    required super.totalPages,
    required super.hasNextPage,
    super.filter,
  });
}

class BookingRequestsCancelling extends BookingRequestsLoaded {
  const BookingRequestsCancelling({
    required super.bookings,
    required super.page,
    required super.totalPages,
    required super.hasNextPage,
    required super.filter,
    required this.bookingId,
  });

  final String bookingId;

  @override
  List<Object?> get props => [...super.props, bookingId];
}

class BookingRequestsError extends BookingRequestsStates {
  const BookingRequestsError(
    this.message, {
    this.filter = BookingStatusFilter.all,
  });

  final String message;
  final BookingStatusFilter filter;

  @override
  List<Object?> get props => [message, filter];
}

class BookingRequestSubmitting extends BookingRequestsStates {
  const BookingRequestSubmitting(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class BookingCreatedSuccessfully extends BookingRequestsStates {
  const BookingCreatedSuccessfully(this.booking);

  final BookingRequestModel booking;

  @override
  List<Object?> get props => [booking];
}

class BookingRequestSubmissionError extends BookingRequestsStates {
  const BookingRequestSubmissionError({
    required this.message,
    required this.submittedMessage,
  });

  final String message;
  final String submittedMessage;

  @override
  List<Object?> get props => [message, submittedMessage];
}

class BookingRoomCheckLoading extends BookingRequestsStates {
  const BookingRoomCheckLoading(this.propertyId, this.roomId);

  final String propertyId;
  final String roomId;

  @override
  List<Object?> get props => [propertyId, roomId];
}

class BookingRoomAvailable extends BookingRequestsStates {
  const BookingRoomAvailable(this.propertyId, this.roomId);

  final String propertyId;
  final String roomId;

  @override
  List<Object?> get props => [propertyId, roomId];
}

class BookingRoomAlreadyRequested extends BookingRequestsStates {
  const BookingRoomAlreadyRequested(this.booking);

  final BookingRequestModel booking;

  @override
  List<Object?> get props => [booking];
}

class BookingRoomCheckError extends BookingRequestsStates {
  const BookingRoomCheckError({
    required this.propertyId,
    required this.roomId,
    required this.message,
  });

  final String propertyId;
  final String roomId;
  final String message;

  @override
  List<Object?> get props => [propertyId, roomId, message];
}
