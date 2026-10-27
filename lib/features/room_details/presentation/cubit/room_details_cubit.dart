import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/features/property_details/data/repositories/property_details_repository.dart';
import 'package:skann_app/features/room_details/presentation/cubit/room_details_state.dart';

class RoomDetailsCubit extends Cubit<RoomDetailsState> {
  RoomDetailsCubit({required this.repository})
    : super(const RoomDetailsState());

  final PropertyDetailsRepository repository;

  int _generation = 0;
  bool _requestInFlight = false;

  Future<void> load(String roomId) async {
    if (isClosed) return;
    if (state.roomId == roomId && state.status == RoomDetailsStatus.loaded) {
      return;
    }
    if (_requestInFlight && state.roomId == roomId) return;

    final generation = ++_generation;
    _requestInFlight = true;
    emit(RoomDetailsState(roomId: roomId, status: RoomDetailsStatus.loading));

    final result = await repository.getRoomDetails(roomId);
    if (isClosed || generation != _generation || state.roomId != roomId) {
      return;
    }
    _requestInFlight = false;

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: RoomDetailsStatus.failure,
          errorMessage: _messageFor(failure),
        ),
      ),
      (room) => emit(
        state.copyWith(
          status: RoomDetailsStatus.loaded,
          room: room,
          clearErrorMessage: true,
        ),
      ),
    );
  }

  String _messageFor(Failure failure) {
    if (failure is NetworkFailure) {
      return 'تعذر الاتصال بالإنترنت. تحقق من اتصالك وحاول مرة أخرى.';
    }
    if (failure is NotFoundFailure) {
      return 'لم نتمكن من العثور على تفاصيل الغرفة.';
    }
    if (failure is ServerFailure) {
      return 'حدث خطأ في الخادم. حاول مرة أخرى لاحقًا.';
    }
    return 'لم نتمكن من تحميل تفاصيل الغرفة حاليًا.';
  }
}
