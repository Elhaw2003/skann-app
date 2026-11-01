import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/features/matching_roommates/data/models/matching_roommates_page_model.dart';
import 'package:skann_app/features/matching_roommates/data/models/roommate_model.dart';
import 'package:skann_app/features/matching_roommates/data/repositories/matching_roommates_repository.dart';
import 'package:skann_app/features/matching_roommates/presentation/cubit/matching_roommates_state.dart';

class MatchingRoommatesCubit extends Cubit<MatchingRoommatesState> {
  MatchingRoommatesCubit({required this.repository})
    : super(const MatchingRoommatesInitial());

  static const int pageSize = 10;

  final MatchingRoommatesRepository repository;
  int _requestGeneration = 0;

  Future<void> load() async {
    if (isClosed || state is MatchingRoommatesLoading) return;
    if (state is MatchingRoommatesLoaded) {
      await refresh();
      return;
    }

    final generation = ++_requestGeneration;
    emit(const MatchingRoommatesLoading());
    final result = await repository.getMatchingRoommates(
      page: 1,
      limit: pageSize,
    );
    if (isClosed || generation != _requestGeneration) return;

    result.fold(
      (failure) => emit(MatchingRoommatesFailure(_messageFor(failure))),
      (page) => emit(_loadedFromPage(page)),
    );
  }

  Future<void> refresh() async {
    final currentState = state;
    if (isClosed) return;
    if (currentState is! MatchingRoommatesLoaded) {
      await load();
      return;
    }
    if (currentState.isRefreshing) return;

    final generation = ++_requestGeneration;
    emit(
      currentState.copyWith(
        isRefreshing: true,
        isLoadingMore: false,
        clearRefreshError: true,
        clearLoadMoreError: true,
      ),
    );
    final result = await repository.getMatchingRoommates(
      page: 1,
      limit: pageSize,
    );
    if (isClosed || generation != _requestGeneration) return;

    result.fold((failure) {
      final latestState = state;
      if (latestState is MatchingRoommatesLoaded) {
        emit(
          latestState.copyWith(
            isRefreshing: false,
            refreshError: _messageFor(failure),
          ),
        );
      }
    }, (page) => emit(_loadedFromPage(page)));
  }

  Future<void> loadNextPage() async {
    final currentState = state;
    if (isClosed ||
        currentState is! MatchingRoommatesLoaded ||
        currentState.isLoadingMore ||
        currentState.isRefreshing ||
        !currentState.pagination.hasNextPage) {
      return;
    }

    final nextPage = currentState.pagination.page + 1;
    if (nextPage > currentState.pagination.totalPages) return;

    final generation = _requestGeneration;
    emit(currentState.copyWith(isLoadingMore: true, clearLoadMoreError: true));
    final result = await repository.getMatchingRoommates(
      page: nextPage,
      limit: pageSize,
    );
    if (isClosed || generation != _requestGeneration) return;

    result.fold(
      (failure) {
        final latestState = state;
        if (latestState is MatchingRoommatesLoaded) {
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
        if (latestState is MatchingRoommatesLoaded) {
          emit(
            latestState.copyWith(
              roommates: _appendUnique(latestState.roommates, page.items),
              pagination: page.pagination,
              isLoadingMore: false,
              clearLoadMoreError: true,
            ),
          );
        }
      },
    );
  }

  MatchingRoommatesLoaded _loadedFromPage(MatchingRoommatesPageModel page) {
    return MatchingRoommatesLoaded(
      roommates: page.items,
      pagination: page.pagination,
    );
  }

  List<RoommateModel> _appendUnique(
    List<RoommateModel> current,
    List<RoommateModel> nextPage,
  ) {
    final knownIds = current.map((roommate) => roommate.id).toSet();
    return List.unmodifiable([
      ...current,
      ...nextPage.where((roommate) => knownIds.add(roommate.id)),
    ]);
  }

  String _messageFor(Failure failure) {
    if (failure is NetworkFailure) {
      return 'تعذر الاتصال بالإنترنت. تحقق من اتصالك وحاول مرة أخرى.';
    }
    if (failure is AuthFailure) {
      return 'انتهت صلاحية جلسة الدخول. سجّل الدخول مرة أخرى للمتابعة.';
    }
    if (failure is ServerFailure) {
      return 'حدث خطأ في الخادم. حاول مرة أخرى لاحقًا.';
    }
    return 'لم نتمكن من تحميل زملاء السكن حاليًا. حاول مرة أخرى.';
  }
}
