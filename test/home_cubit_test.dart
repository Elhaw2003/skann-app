import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/features/home/data/models/amenity_model.dart';
import 'package:skann_app/features/home/data/models/location_model.dart';
import 'package:skann_app/features/home/data/models/property_filters.dart';
import 'package:skann_app/features/home/data/models/property_page_model.dart';
import 'package:skann_app/features/home/data/repositories/amenities_repository.dart';
import 'package:skann_app/features/home/data/repositories/locations_repository.dart';
import 'package:skann_app/features/home/data/repositories/properties_repository.dart';
import 'package:skann_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:skann_app/features/home/presentation/cubit/home_state.dart';

void main() {
  test('initial load starts at page one and emits loaded data', () async {
    final properties = _ControlledPropertiesRepository();
    final cubit = _createCubit(properties);

    final loading = cubit.load();
    expect(cubit.state, isA<HomeLoading>());
    properties.completeNext(
      Right(_page(['property-1'], page: 1, hasNextPage: true)),
    );
    await loading;

    expect(cubit.state, isA<HomeLoaded>());
    final state = cubit.state as HomeLoaded;
    expect(state.properties.single.id, 'property-1');
    expect(properties.requests.single.page, 1);
    expect(properties.requests.single.limit, HomeCubit.pageSize);
    await cubit.close();
  });

  test(
    'search supersedes stale filter responses and resets pagination',
    () async {
      final properties = _ControlledPropertiesRepository();
      final cubit = _createCubit(properties);

      final initialLoad = cubit.load();
      properties.completeNext(
        Right(_page(['initial'], page: 1, hasNextPage: true)),
      );
      await initialLoad;

      final filterRequest = cubit.applyFilters(
        const PropertyFilters(city: 'القاهرة'),
      );
      final searchRequest = cubit.search('شبرا');
      expect(properties.requests[1].page, 1);
      expect(properties.requests[2].page, 1);
      expect(properties.requests[2].filters.city, 'القاهرة');
      expect(properties.requests[2].search, 'شبرا');

      properties.completeNext(
        Right(_page(['stale'], page: 1, hasNextPage: false)),
      );
      await filterRequest;
      expect((cubit.state as HomeLoaded).properties.single.id, 'initial');

      properties.completeNext(
        Right(_page(['fresh'], page: 1, hasNextPage: false)),
      );
      await searchRequest;
      final state = cubit.state as HomeLoaded;
      expect(state.properties.single.id, 'fresh');
      expect(state.search, 'شبرا');
      expect(state.filters.city, 'القاهرة');
      expect(state.isUpdating, isFalse);
      await cubit.close();
    },
  );

  test(
    'pagination prevents duplicate requests and removes duplicate items',
    () async {
      final properties = _ControlledPropertiesRepository();
      final cubit = _createCubit(properties);

      final initialLoad = cubit.load();
      properties.completeNext(
        Right(_page(['one'], page: 1, hasNextPage: true)),
      );
      await initialLoad;

      final nextPage = cubit.loadNextPage();
      expect((cubit.state as HomeLoaded).isLoadingMore, isTrue);
      await cubit.loadNextPage();
      expect(properties.requests, hasLength(2));

      properties.completeNext(
        Right(_page(['one', 'two'], page: 2, hasNextPage: false)),
      );
      await nextPage;
      final state = cubit.state as HomeLoaded;
      expect(state.properties.map((property) => property.id), ['one', 'two']);
      expect(state.pagination.hasNextPage, isFalse);
      await cubit.close();
    },
  );

  test(
    'refresh failure preserves existing results and returns to idle',
    () async {
      final properties = _ControlledPropertiesRepository();
      final cubit = _createCubit(properties);

      final initialLoad = cubit.load();
      properties.completeNext(
        Right(_page(['existing'], page: 1, hasNextPage: false)),
      );
      await initialLoad;

      final refresh = cubit.refresh();
      expect((cubit.state as HomeLoaded).isRefreshing, isTrue);
      properties.completeNext(
        const Left(NetworkFailure('network unavailable')),
      );
      await refresh;

      final state = cubit.state as HomeLoaded;
      expect(state.properties.single.id, 'existing');
      expect(state.isRefreshing, isFalse);
      expect(state.requestError, contains('تعذر الاتصال'));
      await cubit.close();
    },
  );
}

HomeCubit _createCubit(_ControlledPropertiesRepository properties) {
  return HomeCubit(
    propertiesRepository: properties,
    locationsRepository: _LocationsRepository(),
    amenitiesRepository: _AmenitiesRepository(),
  );
}

PropertyPageModel _page(
  List<String> ids, {
  required int page,
  required bool hasNextPage,
}) {
  return PropertyPageModel(
    items: ids
        .map(
          (id) => PropertyPageModel.fromJson(
            {
              'data': {
                'items': [
                  {'id': id, 'title': 'سكن $id'},
                ],
                'pagination': {
                  'page': page,
                  'limit': HomeCubit.pageSize,
                  'totalItems': ids.length,
                  'totalPages': hasNextPage ? page + 1 : page,
                  'hasNextPage': hasNextPage,
                  'hasPreviousPage': page > 1,
                },
              },
            },
            fallbackPage: page,
            fallbackLimit: HomeCubit.pageSize,
          ).items.single,
        )
        .toList(growable: false),
    pagination: PropertyPaginationModel(
      page: page,
      limit: HomeCubit.pageSize,
      totalItems: ids.length,
      totalPages: hasNextPage ? page + 1 : page,
      hasNextPage: hasNextPage,
      hasPreviousPage: page > 1,
    ),
  );
}

class _ControlledPropertiesRepository implements PropertiesRepository {
  final List<Completer<Either<Failure, PropertyPageModel>>> _responses = [];
  final List<_PropertyRequest> requests = [];

  @override
  Future<Either<Failure, PropertyPageModel>> fetchProperties({
    required int page,
    required int limit,
    required PropertyFilters filters,
    String? search,
  }) {
    requests.add(
      _PropertyRequest(
        page: page,
        limit: limit,
        filters: filters,
        search: search,
      ),
    );
    final completer = Completer<Either<Failure, PropertyPageModel>>();
    _responses.add(completer);
    return completer.future;
  }

  void completeNext(Either<Failure, PropertyPageModel> response) {
    _responses.removeAt(0).complete(response);
  }
}

class _PropertyRequest {
  const _PropertyRequest({
    required this.page,
    required this.limit,
    required this.filters,
    required this.search,
  });

  final int page;
  final int limit;
  final PropertyFilters filters;
  final String? search;
}

class _LocationsRepository implements LocationsRepository {
  @override
  Future<Either<Failure, List<LocationModel>>> getLocations() async =>
      const Right([]);
}

class _AmenitiesRepository implements AmenitiesRepository {
  @override
  Future<Either<Failure, List<AmenityModel>>> getAmenities() async =>
      const Right([]);
}
