import 'package:equatable/equatable.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/features/home/data/models/property_model.dart';
import 'package:skann_app/features/property_details/data/models/record_property_view_model.dart';

enum PropertyDetailsStatus { initial, loading, loaded, failure }

enum PropertyViewStatus {
  notAttempted,
  recording,
  recordedNewView,
  alreadyRecorded,
  failed,
}

class PropertyDetailsState extends Equatable {
  const PropertyDetailsState({
    this.propertyId,
    this.status = PropertyDetailsStatus.initial,
    this.property,
    this.errorMessage,
    this.isRefreshing = false,
    this.refreshError,
    this.viewStatus = PropertyViewStatus.notAttempted,
    this.recordedView,
    this.viewFailure,
  });

  final String? propertyId;
  final PropertyDetailsStatus status;
  final PropertyModel? property;
  final String? errorMessage;
  final bool isRefreshing;
  final String? refreshError;
  final PropertyViewStatus viewStatus;
  final RecordPropertyViewModel? recordedView;
  final Failure? viewFailure;

  PropertyDetailsState copyWith({
    String? propertyId,
    PropertyDetailsStatus? status,
    PropertyModel? property,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? isRefreshing,
    String? refreshError,
    bool clearRefreshError = false,
    PropertyViewStatus? viewStatus,
    RecordPropertyViewModel? recordedView,
    Failure? viewFailure,
  }) {
    return PropertyDetailsState(
      propertyId: propertyId ?? this.propertyId,
      status: status ?? this.status,
      property: property ?? this.property,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      refreshError: clearRefreshError
          ? null
          : refreshError ?? this.refreshError,
      viewStatus: viewStatus ?? this.viewStatus,
      recordedView: recordedView ?? this.recordedView,
      viewFailure: viewFailure ?? this.viewFailure,
    );
  }

  @override
  List<Object?> get props => [
    propertyId,
    status,
    property,
    errorMessage,
    isRefreshing,
    refreshError,
    viewStatus,
    recordedView,
    viewFailure,
  ];
}
