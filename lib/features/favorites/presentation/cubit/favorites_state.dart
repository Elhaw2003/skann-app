import 'package:equatable/equatable.dart';
import 'package:skann_app/features/home/data/models/property_model.dart';
import 'package:skann_app/features/home/data/models/property_page_model.dart';

sealed class FavoritesState extends Equatable {
  const FavoritesState({
    required this.hasLoaded,
    this.properties = const [],
    this.pagination = const PropertyPaginationModel(
      page: 1,
      limit: 10,
      totalItems: 0,
      totalPages: 0,
      hasNextPage: false,
      hasPreviousPage: false,
    ),
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.loadMoreError,
    this.propertyOverrides = const {},
    this.pendingPropertyIds = const {},
  });

  final bool hasLoaded;
  final List<PropertyModel> properties;
  final PropertyPaginationModel pagination;
  final bool isRefreshing;
  final bool isLoadingMore;
  final String? errorMessage;
  final String? loadMoreError;
  final Map<String, PropertyModel> propertyOverrides;
  final Set<String> pendingPropertyIds;

  bool get isLoading => this is FavoritesLoading;

  bool isFavorite(PropertyModel property) {
    final id = property.id;
    return id == null
        ? property.isFavorite == true
        : propertyOverrides[id]?.isFavorite ?? property.isFavorite == true;
  }

  FavoritesState copyWith({
    List<PropertyModel>? properties,
    PropertyPaginationModel? pagination,
    bool? isRefreshing,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? loadMoreError,
    bool clearLoadMoreError = false,
    Map<String, PropertyModel>? propertyOverrides,
    Set<String>? pendingPropertyIds,
  }) {
    final nextProperties = properties ?? this.properties;
    final nextPagination = pagination ?? this.pagination;
    final nextIsRefreshing = isRefreshing ?? this.isRefreshing;
    final nextIsLoadingMore = isLoadingMore ?? this.isLoadingMore;
    final nextErrorMessage = clearErrorMessage
        ? null
        : errorMessage ?? this.errorMessage;
    final nextLoadMoreError = clearLoadMoreError
        ? null
        : loadMoreError ?? this.loadMoreError;
    final nextOverrides = propertyOverrides ?? this.propertyOverrides;
    final nextPendingIds = pendingPropertyIds ?? this.pendingPropertyIds;

    if (hasLoaded) {
      return FavoritesSuccess(
        properties: nextProperties,
        pagination: nextPagination,
        isRefreshing: nextIsRefreshing,
        isLoadingMore: nextIsLoadingMore,
        errorMessage: nextErrorMessage,
        loadMoreError: nextLoadMoreError,
        propertyOverrides: nextOverrides,
        pendingPropertyIds: nextPendingIds,
      );
    }

    if (nextErrorMessage != null) {
      return FavoritesFailure(
        message: nextErrorMessage,
        hasLoaded: false,
        properties: nextProperties,
        pagination: nextPagination,
        loadMoreError: nextLoadMoreError,
        propertyOverrides: nextOverrides,
        pendingPropertyIds: nextPendingIds,
      );
    }

    return FavoritesInitial(
      properties: nextProperties,
      pagination: nextPagination,
      propertyOverrides: nextOverrides,
      pendingPropertyIds: nextPendingIds,
    );
  }

  @override
  List<Object?> get props => [
    hasLoaded,
    properties,
    pagination,
    isRefreshing,
    isLoadingMore,
    errorMessage,
    loadMoreError,
    propertyOverrides,
    pendingPropertyIds,
  ];
}

class FavoritesInitial extends FavoritesState {
  const FavoritesInitial({
    super.properties,
    super.pagination,
    super.propertyOverrides,
    super.pendingPropertyIds,
  }) : super(hasLoaded: false);
}

class FavoritesLoading extends FavoritesState {
  const FavoritesLoading({
    required super.hasLoaded,
    super.properties,
    super.pagination,
    super.isRefreshing,
    super.propertyOverrides,
    super.pendingPropertyIds,
  });
}

class FavoritesSuccess extends FavoritesState {
  const FavoritesSuccess({
    required super.properties,
    required super.pagination,
    super.isRefreshing,
    super.isLoadingMore,
    super.errorMessage,
    super.loadMoreError,
    super.propertyOverrides,
    super.pendingPropertyIds,
  }) : super(hasLoaded: true);
}

class FavoritesFailure extends FavoritesState {
  const FavoritesFailure({
    required String message,
    required super.hasLoaded,
    super.properties,
    super.pagination,
    super.loadMoreError,
    super.propertyOverrides,
    super.pendingPropertyIds,
  }) : super(errorMessage: message);
}
