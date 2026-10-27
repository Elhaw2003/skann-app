import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skann_app/core/di.dart';
import 'package:skann_app/features/room_details/presentation/cubit/room_details_cubit.dart';
import 'package:skann_app/features/room_details/presentation/views/widgets/room_details_view.dart';

class RoomDetailsScreen extends StatelessWidget {
  const RoomDetailsScreen({required this.roomId, super.key});

  final String roomId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RoomDetailsCubit>()..load(roomId),
      child: const RoomDetailsView(),
    );
  }
}
