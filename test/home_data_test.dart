import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/core/network/api_consumer.dart';
import 'package:skann_app/features/home/data/models/amenity_model.dart';
import 'package:skann_app/features/home/data/models/location_model.dart';
import 'package:skann_app/features/home/data/models/property_filters.dart';
import 'package:skann_app/features/home/data/models/property_page_model.dart';
import 'package:skann_app/features/home/data/models/property_model.dart';
import 'package:skann_app/features/home/data/repositories/amenities_repository.dart';
import 'package:skann_app/features/home/data/repositories/locations_repository.dart';
import 'package:skann_app/features/home/data/repositories/properties_repository.dart';

void main() {
  test(
    'property model safely parses mixed numeric types and nullable data',
    () {
      final property = PropertyModel.fromJson({
        'id': 'property-1',
        'title': 'سكن الطلاب',
        'thumbnail': 'not-a-url',
        'startingPrice': 1500.5,
        'rating': '4.8',
        'reviewsCount': 3.0,
        'distanceFromUniversity': '5 دقائق',
        'availableRooms': 0,
        'isVerified': false,
        'isFavorite': false,
        'amenities': null,
      });

      expect(property.startingPrice, 1500.5);
      expect(property.rating, 4.8);
      expect(property.reviewsCount, 3);
      expect(property.availableRooms, 0);
      expect(property.isVerified, isFalse);
      expect(property.isFavorite, isFalse);
      expect(property.amenities, isEmpty);
      expect(property.thumbnailUri, isNull);
    },
  );

  test(
    'property pagination preserves explicit false and parses page values',
    () {
      final page = PropertyPageModel.fromJson(
        {
          'success': true,
          'data': {
            'items': [
              {'id': 'one', 'title': 'سكن'},
            ],
            'pagination': {
              'page': 2.0,
              'limit': 10,
              'totalItems': 11,
              'totalPages': 2,
              'hasNextPage': false,
              'hasPreviousPage': true,
            },
          },
        },
        fallbackPage: 1,
        fallbackLimit: 10,
      );

      expect(page.items.single.id, 'one');
      expect(page.pagination.page, 2);
      expect(page.pagination.hasNextPage, isFalse);
      expect(page.pagination.hasPreviousPage, isTrue);
    },
  );

  test(
    'filters send only active values and preserve amenities wire format',
    () {
      const filters = PropertyFilters(
        governorate: ' الجيزة ',
        city: 'القاهرة',
        area: '',
        university: 'جامعة القاهرة',
        propertyType: 'STUDENT_HOUSING',
        genderPolicy: 'MALE',
        minPrice: 0,
        maxPrice: 5000,
        amenities: ['WiFi', 'Air Conditioning', ''],
      );

      expect(filters.toQueryParameters(page: 1, limit: 10, search: 'سكن'), {
        'page': 1,
        'limit': 10,
        'governorate': 'الجيزة',
        'city': 'القاهرة',
        'university': 'جامعة القاهرة',
        'search': 'سكن',
        'propertyType': 'STUDENT_HOUSING',
        'genderPolicy': 'MALE',
        'minPrice': 0,
        'maxPrice': 5000,
        'amenities': 'WiFi,Air Conditioning',
      });
    },
  );

  test('city selection can clear dependent area', () {
    const filters = PropertyFilters(city: 'القاهرة', area: 'مدينة نصر');

    final updatedFilters = filters.copyWith(city: 'الجيزة', clearArea: true);

    expect(updatedFilters.city, 'الجيزة');
    expect(updatedFilters.area, isNull);
  });

  test('location model parses nested city and area names', () {
    final location = LocationModel.fromJson({
      'id': 'cairo',
      'nameAr': 'القاهرة',
      'nameEn': 'Cairo',
      'areas': [
        {'id': 'nasr-city', 'nameAr': 'مدينة نصر', 'nameEn': 'Nasr City'},
      ],
    });

    expect(location.nameAr, 'القاهرة');
    expect(location.areas.single.nameAr, 'مدينة نصر');
  });

  test('amenity model parses semantic icon fields', () {
    final amenity = AmenityModel.fromJson({
      'id': 'amenity-id',
      'name': 'WiFi',
      'icon': 'wifi',
      'category': 'Connectivity',
    });

    expect(amenity.name, 'WiFi');
    expect(amenity.icon, 'wifi');
    expect(amenity.category, 'Connectivity');
  });

  test(
    'properties repository sends exact pagination and filter parameters',
    () async {
      final apiConsumer = _FakeApiConsumer(_propertiesResponse());
      final repository = PropertiesRepositoryImpl(apiConsumer: apiConsumer);

      final result = await repository.fetchProperties(
        page: 2,
        limit: 10,
        search: 'سكن',
        filters: const PropertyFilters(city: 'القاهرة', amenities: ['WiFi']),
      );

      expect(apiConsumer.path, 'properties');
      expect(apiConsumer.queryParameters, {
        'page': 2,
        'limit': 10,
        'city': 'القاهرة',
        'search': 'سكن',
        'amenities': 'WiFi',
      });
      expect(result.isRight(), isTrue);
      expect(
        result.fold((failure) => failure, (page) => page.items.single.id),
        'property-1',
      );
    },
  );

  test('lookup repositories cache only successful API results', () async {
    final locationsApi = _FakeApiConsumer(_locationsResponse());
    final locationsRepository = LocationsRepositoryImpl(
      apiConsumer: locationsApi,
    );
    final locationsFirst = await locationsRepository.getLocations();
    final locationsSecond = await locationsRepository.getLocations();

    expect(locationsApi.requestCount, 1);
    expect(locationsFirst.isRight(), isTrue);
    expect(locationsSecond.isRight(), isTrue);
    final locations = locationsFirst.getOrElse(() => <LocationModel>[]);
    expect(locations.first.nameAr, 'القاهرة');

    final amenitiesApi = _FakeApiConsumer(_amenitiesResponse());
    final amenitiesRepository = AmenitiesRepositoryImpl(
      apiConsumer: amenitiesApi,
    );
    final amenitiesFirst = await amenitiesRepository.getAmenities();
    final amenitiesSecond = await amenitiesRepository.getAmenities();

    expect(amenitiesApi.requestCount, 1);
    expect(amenitiesFirst.isRight(), isTrue);
    expect(amenitiesSecond.isRight(), isTrue);
    final amenities = amenitiesFirst.getOrElse(() => <AmenityModel>[]);
    expect(amenities.first.name, 'WiFi');
  });

  test('repository returns failure for malformed property responses', () async {
    final repository = PropertiesRepositoryImpl(
      apiConsumer: _FakeApiConsumer({
        'success': true,
        'data': <String, Object?>{},
      }),
    );

    final result = await repository.fetchProperties(
      page: 1,
      limit: 10,
      filters: const PropertyFilters(),
    );

    expect(result, isA<Left<Failure, PropertyPageModel>>());
  });
}

Map<String, dynamic> _propertiesResponse() => {
  'success': true,
  'code': 'PROPERTIES_RETRIEVED',
  'message': 'ok',
  'data': {
    'items': [
      {
        'id': 'property-1',
        'title': 'سكن الطلاب',
        'thumbnail': 'https://example.com/image.jpg',
        'city': 'القاهرة',
        'area': 'شبرا',
        'propertyType': 'STUDENT_HOUSING',
        'genderPolicy': 'MALE',
        'startingPrice': 1500,
        'currency': 'EGP',
        'rating': 4.9,
        'reviewsCount': 19,
        'isVerified': true,
        'distanceFromUniversity': '5 دقائق من الجامعة',
        'availableRooms': 1,
        'amenities': ['WiFi'],
        'isFavorite': false,
      },
    ],
    'pagination': {
      'page': 1,
      'limit': 10,
      'totalItems': 1,
      'totalPages': 1,
      'hasNextPage': false,
      'hasPreviousPage': false,
    },
  },
};

Map<String, dynamic> _locationsResponse() => {
  'success': true,
  'data': [
    {
      'id': 'cairo',
      'nameAr': 'القاهرة',
      'nameEn': 'Cairo',
      'areas': [
        {'id': 'nasr-city', 'nameAr': 'مدينة نصر', 'nameEn': 'Nasr City'},
      ],
    },
  ],
};

Map<String, dynamic> _amenitiesResponse() => {
  'success': true,
  'data': [
    {
      'id': 'wifi-id',
      'name': 'WiFi',
      'icon': 'wifi',
      'category': 'Connectivity',
    },
  ],
};

class _FakeApiConsumer implements ApiConsumer {
  _FakeApiConsumer(this.response);

  final Object? response;
  String? path;
  Map<String, dynamic>? queryParameters;
  int requestCount = 0;

  @override
  Future<dynamic> get(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    this.path = path;
    this.queryParameters = queryParameters;
    requestCount++;
    return response;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
