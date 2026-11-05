import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/features/favorites/data/repositories/favorites_repository.dart';
import 'package:skann_app/features/favorites/presentation/cubit/favorites_state.dart';
import 'package:skann_app/features/home/data/models/property_model.dart';
import 'package:skann_app/features/home/data/models/property_page_model.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit({required this.repository}) : super(const FavoritesInitial());

  static const int pageSize = 10;

  final FavoritesRepository repository;
  int _requestGeneration = 0;

  Future<void> loadFavorites() => _loadFirstPage();

  Future<void> refreshFavorites() async {
    if (isClosed || state.isRefreshing || state.isLoadingMore) return;
    await _loadFirstPage();
  }

  Future<void> _loadFirstPage() async {
    if (isClosed ||
        state.isLoading ||
        state.isRefreshing ||
        state.isLoadingMore) {
      return;
    }

    final generation = ++_requestGeneration;
    final hasContent = state.hasLoaded;
    emit(
      FavoritesLoading(
        hasLoaded: hasContent,
        properties: state.properties,
        pagination: state.pagination,
        isRefreshing: hasContent,
        propertyOverrides: state.propertyOverrides,
        pendingPropertyIds: state.pendingPropertyIds,
      ),
    );

    final result = await repository.getFavorites(page: 1, limit: pageSize);
    if (isClosed || generation != _requestGeneration) return;

    result.fold(
      (failure) => emit(
        FavoritesFailure(
          message: _messageFor(failure),
          hasLoaded: hasContent,
          properties: state.properties,
          pagination: state.pagination,
          propertyOverrides: state.propertyOverrides,
          pendingPropertyIds: state.pendingPropertyIds,
        ),
      ),
      (page) {
        final overrides = Map<String, PropertyModel>.from(
          state.propertyOverrides,
        );
        for (final property in page.items) {
          final id = property.id;
          if (id != null && id.trim().isNotEmpty) {
            overrides[id] = property.copyWith(
              isFavorite: property.isFavorite ?? true,
            );
          }
        }
        emit(
          FavoritesSuccess(
            properties: List.unmodifiable(
              page.items.map(
                (property) =>
                    property.copyWith(isFavorite: property.isFavorite ?? true),
              ),
            ),
            pagination: page.pagination,
            propertyOverrides: Map.unmodifiable(overrides),
          ),
        );
      },
    );
  }

  Future<void> loadMoreFavorites() async {
    final currentState = state;
    if (isClosed ||
        !currentState.hasLoaded ||
        currentState.isLoadingMore ||
        currentState.isRefreshing ||
        !currentState.pagination.hasNextPage) {
      return;
    }

    final generation = _requestGeneration;
    emit(currentState.copyWith(isLoadingMore: true, clearLoadMoreError: true));
    final result = await repository.getFavorites(
      page: currentState.pagination.page + 1,
      limit: pageSize,
    );
    if (isClosed || generation != _requestGeneration) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoadingMore: false,
          loadMoreError: _messageFor(failure),
        ),
      ),
      (page) {
        final overrides = Map<String, PropertyModel>.from(
          state.propertyOverrides,
        );
        for (final property in page.items) {
          final id = property.id;
          if (id != null && id.trim().isNotEmpty) {
            overrides[id] = property.copyWith(
              isFavorite: property.isFavorite ?? true,
            );
          }
        }
        emit(
          state.copyWith(
            properties: _appendUnique(state.properties, page.items),
            pagination: page.pagination,
            isLoadingMore: false,
            propertyOverrides: Map.unmodifiable(overrides),
            clearLoadMoreError: true,
          ),
        );
      },
    );
  }

  Future<String?> toggleFavorite(PropertyModel property) async {
    final propertyId = property.id?.trim();
    if (isClosed || propertyId == null || propertyId.isEmpty) {
      return 'تعذر تحديد مكان السكن.';
    }
    if (state.pendingPropertyIds.contains(propertyId)) return null;

    final wasFavorite = state.isFavorite(property);
    final shouldBeFavorite = !wasFavorite;
    final before = state;
    final wasInFavorites = before.properties.any(
      (item) => item.id == propertyId,
    );
    final previousIndex = before.properties.indexWhere(
      (item) => item.id == propertyId,
    );

    _requestGeneration++;
    final pendingIds = {...before.pendingPropertyIds, propertyId};
    final overrides = {
      ...before.propertyOverrides,
      propertyId: property.copyWith(isFavorite: shouldBeFavorite),
    };
    final properties = _updateFavoriteList(
      before.properties,
      property,
      propertyId,
      shouldBeFavorite,
    );
    emit(
      before.copyWith(
        properties: properties,
        pagination: _adjustFavoriteCount(
          before.pagination,
          changed: !wasInFavorites && before.hasLoaded
              ? shouldBeFavorite
                    ? 1
                    : 0
              : wasInFavorites && !shouldBeFavorite
              ? -1
              : 0,
        ),
        isRefreshing: false,
        isLoadingMore: false,
        propertyOverrides: Map.unmodifiable(overrides),
        pendingPropertyIds: Set.unmodifiable(pendingIds),
        clearErrorMessage: true,
        clearLoadMoreError: true,
      ),
    );

    final result = shouldBeFavorite
        ? await repository.addFavorite(propertyId: propertyId)
        : await repository.removeFavorite(propertyId: propertyId);
    if (isClosed) return null;

    final latestState = state;
    final nextPendingIds = {...latestState.pendingPropertyIds}
      ..remove(propertyId);
    return result.fold(
      (failure) {
        final latestOverrides = {...latestState.propertyOverrides}
          ..[propertyId] = property.copyWith(isFavorite: wasFavorite);
        var restoredProperties = latestState.properties;
        if (wasFavorite && wasInFavorites) {
          restoredProperties = _restoreFavorite(
            restoredProperties,
            property.copyWith(isFavorite: true),
            propertyId,
            previousIndex,
          );
        } else if (!wasFavorite) {
          restoredProperties = restoredProperties
              .where((item) => item.id != propertyId)
              .toList(growable: false);
        }
        emit(
          latestState.copyWith(
            properties: List.unmodifiable(restoredProperties),
            pagination: _adjustFavoriteCount(
              latestState.pagination,
              changed: shouldBeFavorite ? -1 : 1,
            ),
            propertyOverrides: Map.unmodifiable(latestOverrides),
            pendingPropertyIds: Set.unmodifiable(nextPendingIds),
          ),
        );
        return _messageFor(failure, isAction: true);
      },
      (_) {
        emit(
          latestState.copyWith(
            pendingPropertyIds: Set.unmodifiable(nextPendingIds),
          ),
        );
        return shouldBeFavorite
            ? 'تمت الإضافة إلى المفضلة.'
            : 'تمت الإزالة من المفضلة.';
      },
    );
  }

  List<PropertyModel> _updateFavoriteList(
    List<PropertyModel> current,
    PropertyModel property,
    String propertyId,
    bool isFavorite,
  ) {
    final existingIndex = current.indexWhere((item) => item.id == propertyId);
    if (!isFavorite) {
      return List.unmodifiable(current.where((item) => item.id != propertyId));
    }
    if (existingIndex >= 0) {
      return List.unmodifiable([
        for (final item in current)
          if (item.id == propertyId) item.copyWith(isFavorite: true) else item,
      ]);
    }
    if (!state.hasLoaded) return current;
    return List.unmodifiable([property.copyWith(isFavorite: true), ...current]);
  }

  List<PropertyModel> _restoreFavorite(
    List<PropertyModel> current,
    PropertyModel property,
    String propertyId,
    int previousIndex,
  ) {
    if (current.any((item) => item.id == propertyId)) return current;
    final restored = [...current];
    restored.insert(previousIndex.clamp(0, restored.length), property);
    return restored;
  }

  PropertyPaginationModel _adjustFavoriteCount(
    PropertyPaginationModel pagination, {
    required int changed,
  }) {
    if (changed == 0) return pagination;
    return PropertyPaginationModel(
      page: pagination.page,
      limit: pagination.limit,
      totalItems: (pagination.totalItems + changed).clamp(0, 0x7fffffff),
      totalPages: pagination.totalPages,
      hasNextPage: pagination.hasNextPage,
      hasPreviousPage: pagination.hasPreviousPage,
    );
  }

  List<PropertyModel> _appendUnique(
    List<PropertyModel> current,
    List<PropertyModel> nextPage,
  ) {
    final ids = current
        .map((property) => property.id)
        .whereType<String>()
        .toSet();
    return List.unmodifiable([
      ...current,
      ...nextPage
          .map(
            (property) =>
                property.copyWith(isFavorite: property.isFavorite ?? true),
          )
          .where((property) {
            final id = property.id;
            return id == null || id.trim().isEmpty || ids.add(id);
          }),
    ]);
  }

  String _messageFor(Failure failure, {bool isAction = false}) {
    if (failure is NetworkFailure) {
      return 'تعذر الاتصال بالإنترنت. تحقق من اتصالك وحاول مرة أخرى.';
    }
    if (failure is AuthFailure) {
      return 'انتهت صلاحية تسجيل الدخول. سجّل الدخول ثم حاول مرة أخرى.';
    }
    if (failure is PermissionFailure) {
      return isAction
          ? 'لا تملك صلاحية تعديل المفضلة.'
          : 'لا تملك صلاحية عرض المفضلة.';
    }
    if (failure is ServerFailure) {
      return 'حدث خطأ في الخادم. حاول مرة أخرى لاحقًا.';
    }
    return isAction
        ? 'لم نتمكن من تحديث المفضلة. حاول مرة أخرى.'
        : 'لم نتمكن من تحميل المفضلة. حاول مرة أخرى.';
  }
}
