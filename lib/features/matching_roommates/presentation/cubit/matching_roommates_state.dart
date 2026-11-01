import 'package:equatable/equatable.dart';
import 'package:skann_app/features/matching_roommates/data/models/matching_roommates_page_model.dart';
import 'package:skann_app/features/matching_roommates/data/models/roommate_model.dart';

sealed class MatchingRoommatesState extends Equatable {
  const MatchingRoommatesState();
}

class MatchingRoommatesInitial extends MatchingRoommatesState {
  const MatchingRoommatesInitial();

  @override
  List<Object?> get props => [];
}

class MatchingRoommatesLoading extends MatchingRoommatesState {
  const MatchingRoommatesLoading();

  @override
  List<Object?> get props => [];
}

class MatchingRoommatesFailure extends MatchingRoommatesState {
  const MatchingRoommatesFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class MatchingRoommatesLoaded extends MatchingRoommatesState {
  const MatchingRoommatesLoaded({
    required this.roommates,
    required this.pagination,
    this.isRefreshing = false,
    this.refreshError,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  final List<RoommateModel> roommates;
  final RoommatePaginationModel pagination;
  final bool isRefreshing;
  final String? refreshError;
  final bool isLoadingMore;
  final String? loadMoreError;

  MatchingRoommatesLoaded copyWith({
    List<RoommateModel>? roommates,
    RoommatePaginationModel? pagination,
    bool? isRefreshing,
    String? refreshError,
    bool clearRefreshError = false,
    bool? isLoadingMore,
    String? loadMoreError,
    bool clearLoadMoreError = false,
  }) {
    return MatchingRoommatesLoaded(
      roommates: roommates ?? this.roommates,
      pagination: pagination ?? this.pagination,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      refreshError: clearRefreshError
          ? null
          : refreshError ?? this.refreshError,
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
    isRefreshing,
    refreshError,
    isLoadingMore,
    loadMoreError,
  ];
}
