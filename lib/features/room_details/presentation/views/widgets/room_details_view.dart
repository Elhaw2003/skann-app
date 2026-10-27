import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                RoomDetailsStatus.loaded => RoomDetailsContent(
                  room: state.room!,
                ),
              };
            },
          ),
        ),
      ),
    );
  }
}
