import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/core/network/api_consumer.dart';
import 'package:skann_app/features/favorites/data/repositories/favorites_repository.dart';
import 'package:skann_app/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:skann_app/features/home/data/models/property_model.dart';
import 'package:skann_app/features/home/data/models/property_page_model.dart';

void main() {
  group('FavoritesRepository', () {
    test('fetches a page and parses properties with existing models', () async {
      final api = _FakeApiConsumer(_favoritesResponse());
      final repository = FavoritesRepositoryImpl(apiConsumer: api);

      final result = await repository.getFavorites(page: 2, limit: 10);

      expect(api.getPath, 'favorites');
      expect(api.getQueryParameters, {'page': 2, 'limit': 10});
      result.fold((failure) => fail(failure.message), (page) {
        expect(page.items.single.id, 'property-1');
        expect(page.items.single.isFavorite, isTrue);
        expect(page.pagination.page, 2);
        expect(page.pagination.hasNextPage, isFalse);
      });
    });

    test(
      'adds and removes without request bodies or query parameters',
      () async {
        final api = _FakeApiConsumer({'success': true});
        final repository = FavoritesRepositoryImpl(apiConsumer: api);

        final addResult = await repository.addFavorite(
          propertyId: 'property-1',
        );
        expect(api.postPath, 'favorites/property-1');
        expect(api.postData, isNull);
        expect(api.postQueryParameters, isNull);
        expect(addResult.isRight(), isTrue);

        final removeResult = await repository.removeFavorite(
          propertyId: 'property-1',
        );
        expect(api.deletePath, 'favorites/property-1');
        expect(api.deleteData, isNull);
        expect(api.deleteQueryParameters, isNull);
        expect(removeResult.isRight(), isTrue);
      },
    );
  });

  test('loads and appends pages without duplicate properties', () async {
    final repository = _FakeFavoritesRepository({
      1: _page([
        _property('property-1'),
      ], _pagination(page: 1, totalItems: 2, hasNextPage: true)),
      2: _page([
        _property('property-1'),
        _property('property-2'),
      ], _pagination(page: 2, totalItems: 2, hasNextPage: false)),
    });
    final cubit = FavoritesCubit(repository: repository);
    await cubit.loadFavorites();

    expect(cubit.state.hasLoaded, isTrue);
    expect(cubit.state.isFavorite(cubit.state.properties.single), isTrue);

    await cubit.loadMoreFavorites();

    expect(repository.requestedPages, [1, 2]);
    expect(cubit.state.properties.map((property) => property.id), [
      'property-1',
      'property-2',
    ]);
    expect(cubit.state.pagination.hasNextPage, isFalse);
    await cubit.close();
  });

  test(
    'represents an empty favorites response as a loaded empty list',
    () async {
      final repository = _FakeFavoritesRepository({
        1: _page(
          const [],
          _pagination(page: 1, totalItems: 0, hasNextPage: false),
        ),
      });
      final cubit = FavoritesCubit(repository: repository);

      await cubit.loadFavorites();

      expect(cubit.state.hasLoaded, isTrue);
      expect(cubit.state.properties, isEmpty);
      expect(cubit.state.pagination.totalItems, 0);
      await cubit.close();
    },
  );

  test(
    'removing a favorite updates shared status and list immediately',
    () async {
      final repository = _FakeFavoritesRepository({
        1: _page([
          _property('property-1'),
        ], _pagination(page: 1, totalItems: 1, hasNextPage: false)),
      });
      final cubit = FavoritesCubit(repository: repository);
      await cubit.loadFavorites();
      final property = cubit.state.properties.single;

      final result = cubit.toggleFavorite(property);

      expect(cubit.state.properties, isEmpty);
      expect(cubit.state.propertyOverrides['property-1']?.isFavorite, isFalse);
      expect(cubit.state.pendingPropertyIds, contains('property-1'));

      expect(await result, 'تمت الإزالة من المفضلة.');
      expect(repository.removedIds, ['property-1']);
      expect(cubit.state.pendingPropertyIds, isEmpty);
      await cubit.close();
    },
  );

  test('returns a success message when a property is added', () async {
    final repository = _FakeFavoritesRepository({});
    final cubit = FavoritesCubit(repository: repository);

    final message = await cubit.toggleFavorite(
      _property('property-2').copyWith(isFavorite: false),
    );

    expect(message, 'تمت الإضافة إلى المفضلة.');
    expect(repository.addedIds, ['property-2']);
    expect(cubit.state.isFavorite(_property('property-2')), isTrue);
    await cubit.close();
  });

  test('keeps existing items when loading the next page fails', () async {
    final repository = _FakeFavoritesRepository({
      1: _page([
        _property('property-1'),
      ], _pagination(page: 1, totalItems: 2, hasNextPage: true)),
    })..nextPageFailure = const NetworkFailure('offline');
    final cubit = FavoritesCubit(repository: repository);
    await cubit.loadFavorites();

    await cubit.loadMoreFavorites();

    expect(cubit.state.properties.map((property) => property.id), [
      'property-1',
    ]);
    expect(cubit.state.loadMoreError, isNotNull);
    expect(cubit.state.isLoadingMore, isFalse);
    await cubit.close();
  });

  test('restores a favorite when removal fails', () async {
    final repository = _FakeFavoritesRepository({
      1: _page([
        _property('property-1'),
      ], _pagination(page: 1, totalItems: 1, hasNextPage: false)),
    })..mutationFailure = const NetworkFailure('offline');
    final cubit = FavoritesCubit(repository: repository);
    await cubit.loadFavorites();

    final error = await cubit.toggleFavorite(cubit.state.properties.single);

    expect(error, isNotNull);
    expect(cubit.state.properties.single.id, 'property-1');
    expect(cubit.state.properties.single.isFavorite, isTrue);
    expect(cubit.state.propertyOverrides['property-1']?.isFavorite, isTrue);
    expect(cubit.state.pagination.totalItems, 1);
    await cubit.close();
  });
}

PropertyModel _property(String id) => PropertyModel(
  id: id,
  title: 'سكن طلابي',
  city: 'القاهرة',
  startingPrice: 2100,
  currency: 'EGP',
  isFavorite: true,
);

PropertyPaginationModel _pagination({
  required int page,
  required int totalItems,
  required bool hasNextPage,
}) => PropertyPaginationModel(
  page: page,
  limit: 10,
  totalItems: totalItems,
  totalPages: hasNextPage ? page + 1 : page,
  hasNextPage: hasNextPage,
  hasPreviousPage: page > 1,
);

PropertyPageModel _page(
  List<PropertyModel> properties,
  PropertyPaginationModel pagination,
) => PropertyPageModel(items: properties, pagination: pagination);

Map<String, dynamic> _favoritesResponse() => {
  'success': true,
  'data': {
    'items': [
      {
        'id': 'property-1',
        'title': 'سكن طلابي',
        'city': 'القاهرة',
        'startingPrice': 2100,
        'currency': 'EGP',
        'isFavorite': true,
      },
    ],
    'pagination': {
      'page': 2,
      'limit': 10,
      'totalItems': 11,
      'totalPages': 2,
      'hasNextPage': false,
      'hasPreviousPage': true,
    },
  },
};

class _FakeApiConsumer extends ApiConsumer {
  _FakeApiConsumer(this.response);

  final Object? response;
  String? getPath;
  String? postPath;
  String? deletePath;
  Map<String, dynamic>? getQueryParameters;
  Map<String, dynamic>? postQueryParameters;
  Map<String, dynamic>? deleteQueryParameters;
  Object? postData;
  Object? deleteData;

  @override
  Future<dynamic> get(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    getPath = path;
    getQueryParameters = queryParameters;
    return response;
  }

  @override
  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool isFromData = false,
  }) async {
    postPath = path;
    postData = data;
    postQueryParameters = queryParameters;
    return response;
  }

  @override
  Future<dynamic> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool isFromData = false,
  }) async {
    deletePath = path;
    deleteData = data;
    deleteQueryParameters = queryParameters;
    return response;
  }

  @override
  Future<dynamic> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool isFromData = false,
  }) async => response;

  @override
  Future<dynamic> put(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool isFromData = false,
  }) async => response;
}

class _FakeFavoritesRepository implements FavoritesRepository {
  _FakeFavoritesRepository(this.pages);

  final Map<int, PropertyPageModel> pages;
  final List<int> requestedPages = [];
  final List<String> addedIds = [];
  final List<String> removedIds = [];
  Failure? nextPageFailure;
  Failure? mutationFailure;

  @override
  Future<Either<Failure, PropertyPageModel>> getFavorites({
    required int page,
    required int limit,
  }) async {
    requestedPages.add(page);
    final failure = nextPageFailure;
    if (page > 1 && failure != null) {
      return Left(failure);
    }
    final result = pages[page];
    if (result == null) {
      return const Left(UnexpectedFailure('Page missing in test fake.'));
    }
    return Right(result);
  }

  @override
  Future<Either<Failure, Unit>> addFavorite({
    required String propertyId,
  }) async {
    addedIds.add(propertyId);
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> removeFavorite({
    required String propertyId,
  }) async {
    removedIds.add(propertyId);
    final failure = mutationFailure;
    if (failure != null) return Left(failure);
    return const Right(unit);
  }
}
