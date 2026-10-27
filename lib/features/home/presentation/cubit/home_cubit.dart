import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/features/home/data/models/amenity_model.dart';
import 'package:skann_app/features/home/data/models/location_model.dart';
import 'package:skann_app/features/home/data/models/property_filters.dart';
import 'package:skann_app/features/home/data/models/property_model.dart';
import 'package:skann_app/features/home/data/models/property_page_model.dart';
import 'package:skann_app/features/home/data/repositories/amenities_repository.dart';
import 'package:skann_app/features/home/data/repositories/locations_repository.dart';
import 'package:skann_app/features/home/data/repositories/properties_repository.dart';
import 'package:skann_app/features/home/presentation/cubit/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required this.propertiesRepository,
    required this.locationsRepository,
    required this.amenitiesRepository,
  }) : super(const HomeInitial());

  static const int pageSize = 10;

  final PropertiesRepository propertiesRepository;
  final LocationsRepository locationsRepository;
  final AmenitiesRepository amenitiesRepository;

  List<LocationModel>? _locations;
  List<AmenityModel>? _amenities;
  bool _isLoadingLocations = false;
  bool _isLoadingAmenities = false;
  String? _locationsError;
  String? _amenitiesError;
  int _requestGeneration = 0;

  Future<void> load() async {
    if (isClosed || state is HomeLoading) return;
    if (state is HomeLoaded) {
      await refresh();
      return;
    }

    final generation = ++_requestGeneration;
    emit(const HomeLoading());
    unawaited(loadLocations());
    unawaited(loadAmenities());
    final result = await propertiesRepository.fetchProperties(
      page: 1,
      limit: pageSize,
      filters: const PropertyFilters(),
    );
    if (isClosed || generation != _requestGeneration) return;

    result.fold(
      (failure) => emit(HomeFailure(_messageFor(failure))),
      (page) => emit(_loadedFromPage(page)),
    );
  }

  Future<void> refresh() async {
    final currentState = state;
    if (isClosed ||
        currentState is! HomeLoaded ||
        currentState.isRefreshing ||
        currentState.isUpdating) {
      return;
    }

    final generation = ++_requestGeneration;
    emit(
      currentState.copyWith(
        isRefreshing: true,
        isLoadingMore: false,
        clearRequestError: true,
        clearLoadMoreError: true,
      ),
    );
    final result = await propertiesRepository.fetchProperties(
      page: 1,
      limit: pageSize,
      filters: currentState.filters,
      search: currentState.search,
    );
    if (isClosed || generation != _requestGeneration) return;

    result.fold(
      (failure) {
        final latestState = state;
        if (latestState is HomeLoaded) {
          emit(
            latestState.copyWith(
              isRefreshing: false,
              isLoadingMore: false,
              requestError: _messageFor(failure),
            ),
          );
        }
      },
      (page) {
        final latestState = state;
        if (latestState is HomeLoaded) {
          emit(
            latestState.copyWith(
              properties: page.items,
              pagination: page.pagination,
              isRefreshing: false,
              isLoadingMore: false,
              clearRequestError: true,
              clearLoadMoreError: true,
            ),
          );
        }
      },
    );
  }

  Future<void> search(String value) async {
    final currentState = state;
    if (currentState is! HomeLoaded) return;
    final normalizedSearch = value.trim();
    if (normalizedSearch == currentState.search) return;
    await _runFirstPage(
      currentState,
      filters: currentState.filters,
      search: normalizedSearch,
    );
  }

  Future<void> applyFilters(PropertyFilters filters) async {
    final currentState = state;
    if (currentState is! HomeLoaded || filters == currentState.filters) return;
    await _runFirstPage(
      currentState,
      filters: filters,
      search: currentState.search,
    );
  }

  Future<void> resetFilters() async {
    await applyFilters(const PropertyFilters());
  }

  Future<void> clearSearchAndFilters() async {
    final currentState = state;
    if (currentState is! HomeLoaded) return;
    if (currentState.filters.isEmpty && currentState.search.isEmpty) return;
    await _runFirstPage(
      currentState,
      filters: const PropertyFilters(),
      search: '',
    );
  }

  Future<void> loadNextPage() async {
    final currentState = state;
    if (isClosed ||
        currentState is! HomeLoaded ||
        currentState.isLoadingMore ||
        currentState.isUpdating ||
        currentState.isRefreshing ||
        !currentState.pagination.hasNextPage) {
      return;
    }

    final generation = _requestGeneration;
    emit(currentState.copyWith(isLoadingMore: true, clearLoadMoreError: true));
    final result = await propertiesRepository.fetchProperties(
      page: currentState.pagination.page + 1,
      limit: pageSize,
      filters: currentState.filters,
      search: currentState.search,
    );
    if (isClosed || generation != _requestGeneration) return;

    result.fold(
      (failure) {
        final latestState = state;
        if (latestState is HomeLoaded) {
          emit(
            latestState.copyWith(
              isLoadingMore: false,
              loadMoreError: _messageFor(failure),
            ),
          );
        }
      },
      (page) {
        final latestState = state;
        if (latestState is HomeLoaded) {
          emit(
            latestState.copyWith(
              properties: _appendUnique(latestState.properties, page),
              pagination: page.pagination,
              isLoadingMore: false,
              clearLoadMoreError: true,
            ),
          );
        }
      },
    );
  }

  Future<void> loadLocations() async {
    if (isClosed || _locations != null || _isLoadingLocations) return;
    _isLoadingLocations = true;
    _locationsError = null;
    _updateLookupState();
    final result = await locationsRepository.getLocations();
    if (isClosed) return;

    _isLoadingLocations = false;
    result.fold((failure) => _locationsError = _lookupMessageFor(failure), (
      locations,
    ) {
      _locations = locations;
      _locationsError = null;
    });
    _updateLookupState();
  }

  Future<void> loadAmenities() async {
    if (isClosed || _amenities != null || _isLoadingAmenities) return;
    _isLoadingAmenities = true;
    _amenitiesError = null;
    _updateLookupState();
    final result = await amenitiesRepository.getAmenities();
    if (isClosed) return;

    _isLoadingAmenities = false;
    result.fold((failure) => _amenitiesError = _lookupMessageFor(failure), (
      amenities,
    ) {
      _amenities = amenities;
      _amenitiesError = null;
    });
    _updateLookupState();
  }

  Future<void> _runFirstPage(
    HomeLoaded currentState, {
    required PropertyFilters filters,
    required String search,
  }) async {
    final generation = ++_requestGeneration;
    emit(
      currentState.copyWith(
        filters: filters,
        search: search,
        isUpdating: true,
        isRefreshing: false,
        isLoadingMore: false,
        clearRequestError: true,
        clearLoadMoreError: true,
      ),
    );
    final result = await propertiesRepository.fetchProperties(
      page: 1,
      limit: pageSize,
      filters: filters,
      search: search,
    );
    if (isClosed || generation != _requestGeneration) return;

    result.fold(
      (failure) {
        final latestState = state;
        if (latestState is HomeLoaded) {
          emit(
            latestState.copyWith(
              isUpdating: false,
              requestError: _messageFor(failure),
            ),
          );
        }
      },
      (page) {
        final latestState = state;
        if (latestState is HomeLoaded) {
          emit(
            latestState.copyWith(
              properties: page.items,
              pagination: page.pagination,
              isUpdating: false,
              clearRequestError: true,
              clearLoadMoreError: true,
            ),
          );
        }
      },
    );
  }

  HomeLoaded _loadedFromPage(PropertyPageModel page) {
    return HomeLoaded(
      properties: page.items,
      pagination: page.pagination,
      locations: _locations ?? const [],
      amenities: _amenities ?? const [],
      isLoadingLocations: _isLoadingLocations,
      isLoadingAmenities: _isLoadingAmenities,
      locationsError: _locationsError,
      amenitiesError: _amenitiesError,
    );
  }

  void _updateLookupState() {
    final currentState = state;
    if (currentState is! HomeLoaded) return;
    emit(
      currentState.copyWith(
        locations: _locations,
        amenities: _amenities,
        isLoadingLocations: _isLoadingLocations,
        isLoadingAmenities: _isLoadingAmenities,
        locationsError: _locationsError,
        clearLocationsError: _locationsError == null,
        amenitiesError: _amenitiesError,
        clearAmenitiesError: _amenitiesError == null,
      ),
    );
  }

  List<PropertyModel> _appendUnique(
    List<PropertyModel> current,
    PropertyPageModel page,
  ) {
    final knownIds = current.map((property) => property.id).toSet();
    return List.unmodifiable([
      ...current,
      ...page.items.where((property) => knownIds.add(property.id)),
    ]);
  }

  String _messageFor(Failure failure) {
    if (failure is NetworkFailure) {
      return 'تعذر الاتصال بالإنترنت. تحقق من اتصالك وحاول مرة أخرى.';
    }
    if (failure is ServerFailure) {
      return 'حدث خطأ في الخادم. حاول مرة أخرى لاحقًا.';
    }
    if (failure is NotFoundFailure) {
      return 'تعذر العثور على البيانات المطلوبة.';
    }
    return 'لم نتمكن من تحميل السكنات حاليًا. حاول مرة أخرى.';
  }

  String _lookupMessageFor(Failure failure) {
    if (failure is NetworkFailure) {
      return 'تعذر الاتصال بالإنترنت لتحميل بيانات الفلاتر.';
    }
    return 'تعذر تحميل بيانات الفلاتر. حاول مرة أخرى.';
  }
}
