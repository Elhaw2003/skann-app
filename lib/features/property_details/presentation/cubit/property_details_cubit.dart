import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/features/property_details/data/repositories/property_details_repository.dart';
import 'package:skann_app/features/property_details/presentation/cubit/property_details_state.dart';

class PropertyDetailsCubit extends Cubit<PropertyDetailsState> {
  PropertyDetailsCubit({required this.repository})
    : super(const PropertyDetailsState());

  final PropertyDetailsRepository repository;

  int _generation = 0;
  bool _detailsRequestInFlight = false;
  bool _roomsRequestInFlight = false;

  void open(String propertyId) {
    if (isClosed) return;
    if (state.propertyId == propertyId &&
        state.status != PropertyDetailsStatus.initial) {
      return;
    }

    final generation = ++_generation;
    _detailsRequestInFlight = false;
    _roomsRequestInFlight = false;
    emit(
      PropertyDetailsState(
        propertyId: propertyId,
        status: PropertyDetailsStatus.loading,
        viewStatus: PropertyViewStatus.recording,
        roomsStatus: PropertyRoomsStatus.loading,
      ),
    );
    unawaited(_loadDetails(propertyId, generation));
    unawaited(_recordView(propertyId, generation));
    unawaited(_loadRooms(propertyId, generation));
  }

  Future<void> loadPropertyDetails(String propertyId) async {
    if (isClosed) return;
    if (state.propertyId != propertyId) {
      open(propertyId);
      return;
    }
    await _loadDetails(propertyId, _generation);
  }

  Future<void> refresh() async {
    final propertyId = state.propertyId;
    if (isClosed ||
        propertyId == null ||
        state.property == null ||
        _detailsRequestInFlight) {
      return;
    }

    await Future.wait([
      _loadDetails(propertyId, _generation, isRefresh: true),
      loadPropertyRooms(propertyId),
    ]);
  }

  Future<void> loadPropertyRooms(String propertyId) async {
    if (isClosed || state.propertyId != propertyId) return;
    await _loadRooms(propertyId, _generation);
  }

  Future<void> _loadDetails(
    String propertyId,
    int generation, {
    bool isRefresh = false,
  }) async {
    if (isClosed || generation != _generation || _detailsRequestInFlight) {
      return;
    }

    _detailsRequestInFlight = true;
    emit(
      state.copyWith(
        status: isRefresh
            ? PropertyDetailsStatus.loaded
            : PropertyDetailsStatus.loading,
        isRefreshing: isRefresh,
        clearErrorMessage: true,
        clearRefreshError: true,
      ),
    );

    final result = await repository.getPropertyDetails(propertyId);
    if (isClosed ||
        generation != _generation ||
        state.propertyId != propertyId) {
      return;
    }
    _detailsRequestInFlight = false;

    result.fold(
      (failure) => _handleDetailsFailure(failure, isRefresh),
      (property) => emit(
        state.copyWith(
          status: PropertyDetailsStatus.loaded,
          property: property,
          isRefreshing: false,
          clearErrorMessage: true,
          clearRefreshError: true,
        ),
      ),
    );
  }

  Future<void> _recordView(String propertyId, int generation) async {
    final result = await repository.recordPropertyView(propertyId);
    if (isClosed ||
        generation != _generation ||
        state.propertyId != propertyId) {
      return;
    }

    result.fold(
      (failure) => emit(
        state.copyWith(
          viewStatus: PropertyViewStatus.failed,
          viewFailure: failure,
        ),
      ),
      (recordedView) => emit(
        state.copyWith(
          viewStatus: recordedView.isNewView
              ? PropertyViewStatus.recordedNewView
              : PropertyViewStatus.notNewView,
          recordedView: recordedView,
        ),
      ),
    );
  }

  Future<void> _loadRooms(String propertyId, int generation) async {
    if (isClosed ||
        generation != _generation ||
        _roomsRequestInFlight ||
        state.propertyId != propertyId) {
      return;
    }

    _roomsRequestInFlight = true;
    emit(
      state.copyWith(
        roomsStatus: PropertyRoomsStatus.loading,
        clearRoomsErrorMessage: true,
      ),
    );
    final result = await repository.getPropertyRooms(propertyId);
    if (isClosed ||
        generation != _generation ||
        state.propertyId != propertyId) {
      return;
    }
    _roomsRequestInFlight = false;

    result.fold(
      (failure) => emit(
        state.copyWith(
          roomsStatus: PropertyRoomsStatus.failure,
          roomsErrorMessage: _roomsMessageFor(failure),
        ),
      ),
      (rooms) => emit(
        state.copyWith(
          rooms: rooms,
          roomsStatus: rooms.isEmpty
              ? PropertyRoomsStatus.empty
              : PropertyRoomsStatus.loaded,
          clearRoomsErrorMessage: true,
        ),
      ),
    );
  }

  void _handleDetailsFailure(Failure failure, bool isRefresh) {
    final message = _messageFor(failure);
    if (isRefresh && state.property != null) {
      emit(
        state.copyWith(
          status: PropertyDetailsStatus.loaded,
          isRefreshing: false,
          refreshError: message,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        status: PropertyDetailsStatus.failure,
        isRefreshing: false,
        errorMessage: message,
      ),
    );
  }

  String _messageFor(Failure failure) {
    if (failure is NetworkFailure) {
      return 'تعذر الاتصال بالإنترنت. تحقق من اتصالك وحاول مرة أخرى.';
    }
    if (failure is NotFoundFailure) {
      return 'لم نتمكن من العثور على مكان السكن المطلوب.';
    }
    if (failure is ServerFailure) {
      return 'حدث خطأ في الخادم. حاول مرة أخرى لاحقًا.';
    }
    return 'لم نتمكن من تحميل تفاصيل السكن حاليًا. حاول مرة أخرى.';
  }

  String _roomsMessageFor(Failure failure) {
    if (failure is NetworkFailure) {
      return 'تعذر تحميل الغرف بسبب مشكلة في الاتصال. حاول مرة أخرى.';
    }
    if (failure is NotFoundFailure) {
      return 'لم نتمكن من العثور على غرف هذا السكن.';
    }
    if (failure is ServerFailure) {
      return 'حدث خطأ أثناء تحميل الغرف. حاول مرة أخرى لاحقًا.';
    }
    return 'لم نتمكن من تحميل الغرف حاليًا. حاول مرة أخرى.';
  }
}
