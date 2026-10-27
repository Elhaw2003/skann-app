import 'package:equatable/equatable.dart';
import 'package:skann_app/features/home/data/models/property_model.dart';

enum RoomDetailsStatus { initial, loading, loaded, failure }

class RoomDetailsState extends Equatable {
  const RoomDetailsState({
    this.roomId,
    this.status = RoomDetailsStatus.initial,
    this.room,
    this.errorMessage,
  });

  final String? roomId;
  final RoomDetailsStatus status;
  final PropertyRoomModel? room;
  final String? errorMessage;

  RoomDetailsState copyWith({
    String? roomId,
    RoomDetailsStatus? status,
    PropertyRoomModel? room,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return RoomDetailsState(
      roomId: roomId ?? this.roomId,
      status: status ?? this.status,
      room: room ?? this.room,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [roomId, status, room, errorMessage];
}
