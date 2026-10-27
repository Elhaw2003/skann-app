import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/core/network/api_consumer.dart';
import 'package:skann_app/features/home/data/models/property_model.dart';
import 'package:skann_app/features/property_details/data/repositories/property_details_repository.dart';

void main() {
  group('Room details repository', () {
    test(
      'fetches a room using its room ID and parses nested property data',
      () async {
        final api = _FakeApiConsumer({
          'success': true,
          'data': {
            'id': 'room-actual-id',
            'name': 'غرفة ماستر',
            'capacity': 1,
            'occupiedBeds': 0,
            'availableBeds': 1,
            'monthlyPrice': 3800,
            'images': [
              {'id': 'image-1', 'url': 'https://example.com/room.jpg'},
            ],
            'amenities': [],
            'property': {
              'id': 'property-actual-id',
              'title': 'سكن الطلاب',
              'city': 'الجيزة',
              'area': 'الدقي',
              'address': 'شارع مصدق',
              'genderPolicy': 'FEMALE',
            },
          },
        });
        final repository = PropertyDetailsRepositoryImpl(apiConsumer: api);

        final result = await repository.getRoomDetails('room-actual-id');

        expect(api.getPath, 'rooms/room-actual-id');
        expect(result.isRight(), isTrue);
        result.fold((_) => fail('Expected room details.'), (room) {
          expect(room.id, 'room-actual-id');
          expect(room.name, 'غرفة ماستر');
          expect(room.monthlyPrice, 3800);
          expect(room.images.single.sortOrder, isNull);
          expect(room.property?.id, 'property-actual-id');
          expect(room.property?.city, 'الجيزة');
        });
      },
    );

    test('rejects an empty room ID without making a request', () async {
      final api = _FakeApiConsumer({});
      final repository = PropertyDetailsRepositoryImpl(apiConsumer: api);

      final result = await repository.getRoomDetails(' ');

      expect(result, isA<Left<Failure, PropertyRoomModel>>());
      expect(api.requestCount, 0);
    });

    test('returns a failure for an invalid room response envelope', () async {
      final repository = PropertyDetailsRepositoryImpl(
        apiConsumer: _FakeApiConsumer({'success': true, 'data': null}),
      );

      final result = await repository.getRoomDetails('room-1');

      expect(result.isLeft(), isTrue);
    });

    test('room model sorts images and keeps nullable details safe', () async {
      final api = _FakeApiConsumer({
        'success': true,
        'data': {
          'id': 'room-2',
          'images': [
            {'url': 'second.jpg', 'sortOrder': 2},
            {'url': 'first.jpg', 'sortOrder': 0},
          ],
          'amenities': [],
        },
      });
      final repository = PropertyDetailsRepositoryImpl(apiConsumer: api);

      final result = await repository.getRoomDetails('room-2');

      result.fold((_) => fail('Expected room details.'), (room) {
        expect(room.name, isNull);
        expect(room.images.map((image) => image.url), [
          'first.jpg',
          'second.jpg',
        ]);
        expect(room.property, isNull);
      });
    });
  });
}

class _FakeApiConsumer extends ApiConsumer {
  _FakeApiConsumer(this.response);

  final Object? response;
  String? getPath;
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
  }) async => response;

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
