import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/features/matching_roommates/data/models/matching_roommates_page_model.dart';
import 'package:skann_app/features/matching_roommates/data/models/roommate_model.dart';
import 'package:skann_app/features/matching_roommates/data/models/roommates_directory_filters.dart';
import 'package:skann_app/features/matching_roommates/data/repositories/matching_roommates_repository.dart';
import 'package:skann_app/features/matching_roommates/presentation/cubit/roommates_directory_state.dart';

class RoommatesDirectoryCubit extends Cubit<RoommatesDirectoryState> {
  RoommatesDirectoryCubit({required this.repository})
    : super(const RoommatesDirectoryInitial());

  static const int pageSize = 10;

  final MatchingRoommatesRepository repository;
  int _requestGeneration = 0;

  Future<void> load() async {
    if (isClosed ||
        state is RoommatesDirectoryLoading ||
        state is RoommatesDirectoryLoaded) {
      return;
    }

    final generation = ++_requestGeneration;
    emit(const RoommatesDirectoryLoading());
    final result = await _requestPage(
      page: 1,
      filters: const RoommatesDirectoryFilters(),
    );
    if (isClosed || generation != _requestGeneration) return;

    result.fold(
      (failure) => emit(RoommatesDirectoryFailure(_messageFor(failure))),
      (page) => emit(_loadedFromPage(page)),
    );
  }

  Future<void> refresh() async {
    final currentState = state;
    if (isClosed) return;
    if (currentState is! RoommatesDirectoryLoaded) {
      await load();
      return;
    }
    if (currentState.isRefreshing || currentState.isUpdating) return;

    final generation = ++_requestGeneration;
    emit(
      currentState.copyWith(
        isRefreshing: true,
        isLoadingMore: false,
        clearRefreshError: true,
        clearRequestError: true,
        clearLoadMoreError: true,
      ),
    );
    final result = await _requestPage(page: 1, filters: currentState.filters);
    if (isClosed || generation != _requestGeneration) return;

    result.fold(
      (failure) {
        final latestState = state;
        if (latestState is RoommatesDirectoryLoaded) {
          emit(
            latestState.copyWith(
              isRefreshing: false,
              refreshError: _messageFor(failure),
            ),
          );
        }
      },
      (page) => emit(
        _loadedFromPage(
          page,
          filters: currentState.filters,
          search: currentState.search,
        ),
      ),
    );
  }

  Future<void> loadNextPage() async {
    final currentState = state;
    if (isClosed ||
        currentState is! RoommatesDirectoryLoaded ||
        currentState.isLoadingMore ||
        currentState.isRefreshing ||
        currentState.isUpdating ||
        !currentState.pagination.hasNextPage) {
      return;
    }

    final nextPage = currentState.pagination.page + 1;
    if (nextPage > currentState.pagination.totalPages) return;

    final generation = _requestGeneration;
    emit(currentState.copyWith(isLoadingMore: true, clearLoadMoreError: true));
    final result = await _requestPage(
      page: nextPage,
      filters: currentState.filters,
    );
    if (isClosed || generation != _requestGeneration) return;

    result.fold(
      (failure) {
        final latestState = state;
        if (latestState is RoommatesDirectoryLoaded) {
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
        if (latestState is RoommatesDirectoryLoaded) {
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

  Future<void> applyFilters(RoommatesDirectoryFilters filters) async {
    final currentState = state;
    if (isClosed) return;
    if (currentState is! RoommatesDirectoryLoaded) {
      await load();
      return;
    }
    if (currentState.filters == filters || currentState.isUpdating) return;

    final generation = ++_requestGeneration;
    emit(
      currentState.copyWith(
        isUpdating: true,
        isRefreshing: false,
        isLoadingMore: false,
        clearRequestError: true,
        clearRefreshError: true,
        clearLoadMoreError: true,
      ),
    );
    final result = await _requestPage(page: 1, filters: filters);
    if (isClosed || generation != _requestGeneration) return;

    result.fold(
      (failure) {
        final latestState = state;
        if (latestState is RoommatesDirectoryLoaded) {
          emit(
            latestState.copyWith(
              isUpdating: false,
              requestError: _messageFor(failure),
            ),
          );
        }
      },
      (page) => emit(
        _loadedFromPage(page, filters: filters, search: currentState.search),
      ),
    );
  }

  Future<void> resetFilters() =>
      applyFilters(const RoommatesDirectoryFilters());

  void updateSearch(String value) {
    final currentState = state;
    if (isClosed || currentState is! RoommatesDirectoryLoaded) return;
    final normalizedSearch = value.trim();
    if (normalizedSearch == currentState.search) return;
    emit(currentState.copyWith(search: normalizedSearch));
  }

  Future<Either<Failure, MatchingRoommatesPageModel>> _requestPage({
    required int page,
    required RoommatesDirectoryFilters filters,
  }) {
    return repository.getRoommatesDirectory(
      page: page,
      limit: pageSize,
      governorate: filters.governorate,
      university: filters.university,
      faculty: filters.faculty,
    );
  }

  RoommatesDirectoryLoaded _loadedFromPage(
    MatchingRoommatesPageModel page, {
    RoommatesDirectoryFilters filters = const RoommatesDirectoryFilters(),
    String search = '',
  }) {
    return RoommatesDirectoryLoaded(
      roommates: page.items,
      pagination: page.pagination,
      filters: filters,
      search: search,
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
    return 'لم نتمكن من تحميل دليل زملاء السكن. حاول مرة أخرى.';
  }
}
