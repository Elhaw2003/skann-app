import 'package:equatable/equatable.dart';
import 'package:skann_app/features/matching_roommates/data/models/matching_roommates_page_model.dart';
import 'package:skann_app/features/matching_roommates/data/models/roommate_model.dart';
import 'package:skann_app/features/matching_roommates/data/models/roommates_directory_filters.dart';

sealed class RoommatesDirectoryState extends Equatable {
  const RoommatesDirectoryState();
}

class RoommatesDirectoryInitial extends RoommatesDirectoryState {
  const RoommatesDirectoryInitial();

  @override
  List<Object?> get props => [];
}

class RoommatesDirectoryLoading extends RoommatesDirectoryState {
  const RoommatesDirectoryLoading();

  @override
  List<Object?> get props => [];
}

class RoommatesDirectoryFailure extends RoommatesDirectoryState {
  const RoommatesDirectoryFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class RoommatesDirectoryLoaded extends RoommatesDirectoryState {
  const RoommatesDirectoryLoaded({
    required this.roommates,
    required this.pagination,
    this.filters = const RoommatesDirectoryFilters(),
    this.search = '',
    this.isUpdating = false,
    this.isRefreshing = false,
    this.refreshError,
    this.requestError,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  final List<RoommateModel> roommates;
  final RoommatePaginationModel pagination;
  final RoommatesDirectoryFilters filters;
  final String search;
  final bool isUpdating;
  final bool isRefreshing;
  final String? refreshError;
  final String? requestError;
  final bool isLoadingMore;
  final String? loadMoreError;

  List<RoommateModel> get visibleRoommates {
    final query = search.trim().toLowerCase();
    if (query.isEmpty) return roommates;
    return roommates
        .where((roommate) {
          return [roommate.fullName, roommate.university, roommate.faculty]
              .whereType<String>()
              .any((value) => value.toLowerCase().contains(query));
        })
        .toList(growable: false);
  }

  RoommatesDirectoryLoaded copyWith({
    List<RoommateModel>? roommates,
    RoommatePaginationModel? pagination,
    RoommatesDirectoryFilters? filters,
    String? search,
    bool? isUpdating,
    bool? isRefreshing,
    String? refreshError,
    bool clearRefreshError = false,
    String? requestError,
    bool clearRequestError = false,
    bool? isLoadingMore,
    String? loadMoreError,
    bool clearLoadMoreError = false,
  }) {
    return RoommatesDirectoryLoaded(
      roommates: roommates ?? this.roommates,
      pagination: pagination ?? this.pagination,
      filters: filters ?? this.filters,
      search: search ?? this.search,
      isUpdating: isUpdating ?? this.isUpdating,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      refreshError: clearRefreshError
          ? null
          : refreshError ?? this.refreshError,
      requestError: clearRequestError
          ? null
          : requestError ?? this.requestError,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError: clearLoadMoreError
          ? null
          : loadMoreError ?? this.loadMoreError,
    );
  }

  @override
  List<Object?> get props => [
    roommates,
    pagination,
    filters,
    search,
    isUpdating,
    isRefreshing,
    refreshError,
    requestError,
    isLoadingMore,
    loadMoreError,
  ];
}
