import 'package:equatable/equatable.dart';
import 'package:skann_app/features/home/data/models/amenity_model.dart';
import 'package:skann_app/features/home/data/models/location_model.dart';
import 'package:skann_app/features/home/data/models/property_filters.dart';
import 'package:skann_app/features/home/data/models/property_model.dart';
import 'package:skann_app/features/home/data/models/property_page_model.dart';

sealed class HomeState extends Equatable {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();

  @override
  List<Object?> get props => [];
}

class HomeLoading extends HomeState {
  const HomeLoading();

  @override
  List<Object?> get props => [];
}

class HomeFailure extends HomeState {
  const HomeFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class HomeLoaded extends HomeState {
  const HomeLoaded({
    required this.properties,
    required this.pagination,
    this.filters = const PropertyFilters(),
    this.search = '',
    this.isUpdating = false,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.requestError,
    this.loadMoreError,
    this.locations = const [],
    this.amenities = const [],
    this.isLoadingLocations = false,
    this.isLoadingAmenities = false,
    this.locationsError,
    this.amenitiesError,
  });

  final List<PropertyModel> properties;
  final PropertyPaginationModel pagination;
  final PropertyFilters filters;
  final String search;
  final bool isUpdating;
  final bool isRefreshing;
  final bool isLoadingMore;
  final String? requestError;
  final String? loadMoreError;
  final List<LocationModel> locations;
  final List<AmenityModel> amenities;
  final bool isLoadingLocations;
  final bool isLoadingAmenities;
  final String? locationsError;
  final String? amenitiesError;

  HomeLoaded copyWith({
    List<PropertyModel>? properties,
    PropertyPaginationModel? pagination,
    PropertyFilters? filters,
    String? search,
    bool? isUpdating,
    bool? isRefreshing,
    bool? isLoadingMore,
    String? requestError,
    bool clearRequestError = false,
    String? loadMoreError,
    bool clearLoadMoreError = false,
    List<LocationModel>? locations,
    List<AmenityModel>? amenities,
    bool? isLoadingLocations,
    bool? isLoadingAmenities,
    String? locationsError,
    bool clearLocationsError = false,
    String? amenitiesError,
    bool clearAmenitiesError = false,
  }) {
    return HomeLoaded(
      properties: properties ?? this.properties,
      pagination: pagination ?? this.pagination,
      filters: filters ?? this.filters,
      search: search ?? this.search,
      isUpdating: isUpdating ?? this.isUpdating,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      requestError: clearRequestError
          ? null
          : requestError ?? this.requestError,
      loadMoreError: clearLoadMoreError
          ? null
          : loadMoreError ?? this.loadMoreError,
      locations: locations ?? this.locations,
      amenities: amenities ?? this.amenities,
      isLoadingLocations: isLoadingLocations ?? this.isLoadingLocations,
      isLoadingAmenities: isLoadingAmenities ?? this.isLoadingAmenities,
      locationsError: clearLocationsError
          ? null
          : locationsError ?? this.locationsError,
      amenitiesError: clearAmenitiesError
          ? null
          : amenitiesError ?? this.amenitiesError,
    );
  }

  @override
  List<Object?> get props => [
    properties,
    pagination,
    filters,
    search,
    isUpdating,
    isRefreshing,
    isLoadingMore,
    requestError,
    loadMoreError,
    locations,
    amenities,
    isLoadingLocations,
    isLoadingAmenities,
    locationsError,
    amenitiesError,
  ];
}
