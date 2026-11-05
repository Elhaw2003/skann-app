import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skann_app/features/booking_requests/presentation/cubit/booking_requests_cubit.dart';
import 'package:skann_app/features/room_details/presentation/cubit/room_details_cubit.dart';
import 'package:skann_app/features/room_details/presentation/cubit/room_details_state.dart';
import 'package:skann_app/features/room_details/presentation/views/widgets/room_details_content.dart';
import 'package:skann_app/features/room_details/presentation/views/widgets/room_details_states.dart';

class RoomDetailsView extends StatelessWidget {
  const RoomDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FB),
        body: SafeArea(
          child: BlocListener<RoomDetailsCubit, RoomDetailsState>(
            listenWhen: (previous, current) =>
                previous.status != RoomDetailsStatus.loaded &&
                current.status == RoomDetailsStatus.loaded,
            listener: (context, state) {
              final room = state.room;
              if (room == null) return;
              context.read<BookingRequestsCubit>().checkRoomBooking(
                propertyId: room.property?.id ?? '',
                roomId: room.id ?? '',
              );
            },
            child: BlocBuilder<RoomDetailsCubit, RoomDetailsState>(
              builder: (context, state) {
                return switch (state.status) {
                  RoomDetailsStatus.initial ||
                  RoomDetailsStatus.loading => const RoomDetailsLoadingView(),
                  RoomDetailsStatus.failure => RoomDetailsErrorView(
                    message: state.errorMessage ?? 'تعذر تحميل تفاصيل الغرفة.',
                    onRetry: () {
                      final roomId = state.roomId;
                      if (roomId != null) {
                        context.read<RoomDetailsCubit>().load(roomId);
                      }
                    },
                  ),
                  RoomDetailsStatus.loaded => _buildLoadedRoom(context, state),
                };
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadedRoom(BuildContext context, RoomDetailsState state) {
    final room = state.room;
    if (room != null) return RoomDetailsContent(room: room);

    return RoomDetailsErrorView(
      message: 'تعذر تحميل تفاصيل الغرفة.',
      onRetry: () {
        final roomId = state.roomId;
        if (roomId != null) context.read<RoomDetailsCubit>().load(roomId);
      },
    );
  }
}
