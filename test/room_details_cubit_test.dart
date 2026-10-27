import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/features/home/data/models/property_model.dart';
import 'package:skann_app/features/property_details/data/models/record_property_view_model.dart';
import 'package:skann_app/features/property_details/data/repositories/property_details_repository.dart';
import 'package:skann_app/features/room_details/presentation/cubit/room_details_cubit.dart';
import 'package:skann_app/features/room_details/presentation/cubit/room_details_state.dart';

void main() {
  test(
    'loads room details by room ID and avoids duplicate loaded requests',
    () async {
      final repository = _RoomDetailsRepository();
      final cubit = RoomDetailsCubit(repository: repository);

      await cubit.load('room-1');
      await cubit.load('room-1');

      expect(repository.requestedRoomIds, ['room-1']);
      expect(cubit.state.status, RoomDetailsStatus.loaded);
      expect(cubit.state.room?.id, 'room-1');
      expect(cubit.state.room?.property?.id, 'property-1');

      await cubit.close();
    },
  );

  test('exposes an error state and allows a deliberate retry', () async {
    final repository = _RoomDetailsRepository()
      ..roomResult = const Left(NetworkFailure('offline'));
    final cubit = RoomDetailsCubit(repository: repository);

    await cubit.load('room-1');
    expect(cubit.state.status, RoomDetailsStatus.failure);
    expect(cubit.state.errorMessage, isNotEmpty);

    repository.roomResult = Right(
      const PropertyRoomModel(id: 'room-1', name: 'غرفة'),
    );
    await cubit.load('room-1');

    expect(repository.requestedRoomIds, ['room-1', 'room-1']);
    expect(cubit.state.status, RoomDetailsStatus.loaded);
    await cubit.close();
  });
}

class _RoomDetailsRepository implements PropertyDetailsRepository {
  final List<String> requestedRoomIds = [];
  Either<Failure, PropertyRoomModel> roomResult = const Right(
    PropertyRoomModel(
      id: 'room-1',
      property: PropertyRoomPropertyModel(id: 'property-1'),
    ),
  );

  @override
  Future<Either<Failure, PropertyRoomModel>> getRoomDetails(
    String roomId,
  ) async {
    requestedRoomIds.add(roomId);
    return roomResult;
  }

  @override
  Future<Either<Failure, PropertyModel>> getPropertyDetails(
    String propertyId,
  ) async => const Left(UnexpectedFailure('Not used in this test.'));

  @override
  Future<Either<Failure, List<PropertyRoomModel>>> getPropertyRooms(
    String propertyId,
  ) async => const Left(UnexpectedFailure('Not used in this test.'));

  @override
  Future<Either<Failure, RecordPropertyViewModel>> recordPropertyView(
    String propertyId,
  ) async => const Left(UnexpectedFailure('Not used in this test.'));
}
