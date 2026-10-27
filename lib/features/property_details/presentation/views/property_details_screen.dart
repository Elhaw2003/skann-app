import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skann_app/core/di.dart';
import 'package:skann_app/features/property_details/presentation/cubit/property_details_cubit.dart';
import 'package:skann_app/features/property_details/presentation/views/widgets/property_details_view.dart';

class PropertyDetailsScreen extends StatelessWidget {
  const PropertyDetailsScreen({required this.propertyId, super.key});

  final String propertyId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PropertyDetailsCubit>()..open(propertyId),
      child: const PropertyDetailsView(),
    );
  }
}
