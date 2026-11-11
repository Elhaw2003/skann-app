import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skann_app/core/di.dart';
import 'package:skann_app/features/property_details/presentation/cubit/property_details_cubit.dart';
import 'package:skann_app/features/property_details/presentation/views/widgets/property_details_view.dart';
import 'package:skann_app/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:skann_app/features/chat/presentation/cubit/chat_launcher_cubit.dart';

class PropertyDetailsScreen extends StatelessWidget {
  const PropertyDetailsScreen({required this.propertyId, super.key});

  final String propertyId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<FavoritesCubit>(),
      child: BlocProvider(
        create: (_) => sl<ChatLauncherCubit>(),
        child: BlocProvider(
          create: (_) => sl<PropertyDetailsCubit>()..open(propertyId),
          child: const PropertyDetailsView(),
        ),
      ),
    );
  }
}
