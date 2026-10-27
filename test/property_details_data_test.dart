import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/core/network/api_consumer.dart';
import 'package:skann_app/features/home/data/models/property_model.dart';
import 'package:skann_app/features/property_details/data/models/record_property_view_model.dart';
import 'package:skann_app/features/property_details/data/repositories/property_details_repository.dart';

void main() {
  group('PropertyModel', () {
    test('parses nested property data and sorts images by sort order', () {
      final property = PropertyModel.fromJson(_fullProperty());

      expect(property.id, 'property-actual-id');
      expect(property.images.map((image) => image.url), [
        'https://example.com/first.jpg',
        'https://example.com/second.jpg',
      ]);
      expect(property.location?.city, 'القاهرة');
      expect(property.amenities.single.name, 'واي فاي');
      expect(property.rooms.single.availableBeds, 2);
      expect(property.rooms.single.id, isNull);
      expect(property.rooms.single.monthlyPrice, 2400.5);
      expect(property.currentResidents.single.academicYear, 'الثالثة');
      expect(property.owner?.name, 'صاحب السكن');
    });

    test('handles missing optional fields and empty nested lists', () {
      final property = PropertyModel.fromJson({
        'id': 'property-1',
        'title': 'سكن',
        'images': [],
        'amenities': [],
        'rooms': [],
        'currentResidents': [],
        'rating': null,
        'reviewsCount': null,
      });

      expect(property.images, isEmpty);
      expect(property.amenities, isEmpty);
      expect(property.rooms, isEmpty);
      expect(property.currentResidents, isEmpty);
      expect(property.location, isNull);
      expect(property.owner, isNull);
      expect(property.rating, isNull);
      expect(property.reviewsCount, isNull);
    });

    test('accepts missing property values and malformed optional fields', () {
      final property = PropertyModel.fromJson({
        'images': 'unexpected',
        'amenities': [null, 3, 'واي فاي'],
        'rooms': null,
        'currentResidents': [],
        'rating': 'not-a-number',
        'isVerified': 'yes',
      });

      expect(property.id, isNull);
      expect(property.title, isNull);
      expect(property.images, isEmpty);
      expect(property.amenities.single.name, 'واي فاي');
      expect(property.rooms, isEmpty);
      expect(property.currentResidents, isEmpty);
      expect(property.rating, isNull);
      expect(property.isVerified, isNull);
    });

    test('record view uses isNewView even when the response count is zero', () {
      final newView = RecordPropertyViewModel.fromJson({
        'propertyId': 'property-1',
        'viewsCount': 0,
        'isNewView': true,
      });
      final repeatedView = RecordPropertyViewModel.fromJson({
        'propertyId': 'property-1',
        'viewsCount': 0,
        'isNewView': false,
      });

      expect(newView.isNewView, isTrue);
      expect(newView.viewsCount, 0);
      expect(repeatedView.isNewView, isFalse);
      expect(repeatedView.viewsCount, 0);
    });
  });

  group('PropertyDetailsRepository', () {
    test('uses the property ID in details and record-view paths', () async {
      final api = _FakeApiConsumer(_detailsResponse());
      final repository = PropertyDetailsRepositoryImpl(apiConsumer: api);

      final detailsResult = await repository.getPropertyDetails(
        'backend-id-42',
      );
      api.response = {
        'success': true,
        'data': {
          'propertyId': 'backend-id-42',
          'viewsCount': 0,
          'isNewView': false,
        },
      };
      final viewResult = await repository.recordPropertyView('backend-id-42');

      expect(api.getPath, 'properties/backend-id-42');
      expect(api.postPath, 'properties/backend-id-42/view');
      expect(detailsResult.isRight(), isTrue);
      expect(
        viewResult.fold((failure) => failure, (view) => view.isNewView),
        isFalse,
      );
    });

    test('rejects invalid IDs without making a network request', () async {
      final api = _FakeApiConsumer(_detailsResponse());
      final repository = PropertyDetailsRepositoryImpl(apiConsumer: api);

      final result = await repository.getPropertyDetails('  ');

      expect(result, isA<Left<Failure, PropertyModel>>());
      expect(api.requestCount, 0);
    });

    test('returns a failure for an invalid response envelope', () async {
      final repository = PropertyDetailsRepositoryImpl(
        apiConsumer: _FakeApiConsumer({'success': true, 'data': null}),
      );

      final result = await repository.getPropertyDetails('property-1');

      expect(result, isA<Left<Failure, PropertyModel>>());
    });

    test(
      'loads property rooms from the dedicated property rooms endpoint',
      () async {
        final api = _FakeApiConsumer({
          'success': true,
          'data': [
            {
              'id': 'room-1',
              'name': 'غرفة',
              'capacity': 2,
              'images': [
                {'id': 'later', 'url': 'second.jpg', 'sortOrder': 2},
                {'id': 'first', 'url': 'first.jpg', 'sortOrder': 0},
              ],
            },
          ],
        });
        final repository = PropertyDetailsRepositoryImpl(apiConsumer: api);

        final result = await repository.getPropertyRooms('backend-id-42');

        expect(api.getPath, 'properties/backend-id-42/rooms');
        expect(result.isRight(), isTrue);
        result.fold((_) => fail('Expected rooms to load.'), (rooms) {
          expect(rooms.single.id, 'room-1');
          expect(rooms.single.images.map((image) => image.url), [
            'first.jpg',
            'second.jpg',
          ]);
        });
      },
    );

    test('parses an empty rooms response as an empty list', () async {
      final repository = PropertyDetailsRepositoryImpl(
        apiConsumer: _FakeApiConsumer({'success': true, 'data': []}),
      );

      final result = await repository.getPropertyRooms('property-1');

      expect(result.fold((_) => null, (rooms) => rooms), isEmpty);
    });

    test('returns a failure when rooms data is not a list', () async {
      final repository = PropertyDetailsRepositoryImpl(
        apiConsumer: _FakeApiConsumer({
          'success': true,
          'data': {'id': 'not-a-list'},
        }),
      );

      final result = await repository.getPropertyRooms('property-1');

      expect(result.isLeft(), isTrue);
    });
  });
}

Map<String, dynamic> _fullProperty() => {
  'id': 'property-actual-id',
  'title': 'سكن قريب من الجامعة',
  'description': 'وصف السكن',
  'propertyType': 'STUDENT_HOUSING',
  'genderPolicy': 'MALE',
  'rating': 4.7,
  'reviewsCount': 9,
  'viewsCount': 0,
  'favoritesCount': 2,
  'isVerified': true,
  'distanceFromUniversity': '5 دقائق من الجامعة',
  'currentOccupants': 3,
  'images': [
    {'id': 'second', 'url': 'https://example.com/second.jpg', 'sortOrder': 2},
    {'id': 'first', 'url': 'https://example.com/first.jpg', 'sortOrder': 1},
  ],
  'location': {
    'city': 'القاهرة',
    'area': 'الدقي',
    'address': 'شارع الجامعة',
    'latitude': '30.04',
    'longitude': 31.21,
  },
  'amenities': [
    {'id': 'wifi', 'name': 'واي فاي', 'icon': 'wifi', 'category': 'general'},
  ],
  'owner': {
    'id': 'owner-1',
    'name': 'صاحب السكن',
    'profileImage': 'https://example.com/owner.jpg',
  },
  'rooms': [
    {
      'name': 'غرفة مزدوجة',
      'description': 'غرفة مريحة',
      'capacity': 4,
      'occupiedBeds': 2,
      'availableBeds': 2,
      'monthlyPrice': 2400.5,
      'images': ['https://example.com/room.jpg'],
      'amenities': [
        {'id': 'desk', 'name': 'مكتب', 'icon': 'desk'},
      ],
    },
  ],
  'currentResidents': [
    {
      'fullName': 'طالب',
      'profileImage': null,
      'university': 'جامعة القاهرة',
      'faculty': 'الهندسة',
      'major': 'مدني',
      'academicYear': 'الثالثة',
      'roomName': 'غرفة مزدوجة',
      'interests': ['قراءة'],
    },
  ],
  'isFavorite': false,
};

Map<String, dynamic> _detailsResponse() => {
  'success': true,
  'data': {'id': 'property-1', 'title': 'سكن'},
};

class _FakeApiConsumer extends ApiConsumer {
  _FakeApiConsumer(this.response);

  Object? response;
  String? getPath;
  String? postPath;
  int requestCount = 0;

  @override
  Future<dynamic> get(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    getPath = path;
    requestCount++;
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
    requestCount++;
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
  Future<dynamic> delete(
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
