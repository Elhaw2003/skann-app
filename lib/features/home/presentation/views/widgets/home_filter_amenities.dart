import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/features/home/data/models/amenity_model.dart';
import 'package:skann_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:skann_app/features/home/presentation/cubit/home_state.dart';
import 'package:skann_app/features/home/presentation/views/widgets/amenity_icon_mapping.dart';
import 'package:skann_app/features/home/presentation/views/widgets/home_filter_components.dart';

class HomeFilterAmenities extends StatelessWidget {
  const HomeFilterAmenities({
    required this.selectedAmenities,
    required this.onChanged,
    super.key,
  });

  final Set<String> selectedAmenities;
  final void Function(AmenityModel amenity, bool selected) onChanged;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is! HomeLoaded) return const SizedBox.shrink();
        final groupedAmenities = _groupAmenities(state.amenities);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HomeFilterSectionLabel(
              label: 'الخدمات والمرافق',
              icon: Icons.spa_outlined,
              trailing: selectedAmenities.isEmpty
                  ? null
                  : '${selectedAmenities.length} محددة',
            ),
            if (state.isLoadingAmenities)
              const Padding(
                padding: EdgeInsets.all(14),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else if (state.amenitiesError != null)
              HomeLookupError(
                message: state.amenitiesError ?? '',
                onRetry: context.read<HomeCubit>().loadAmenities,
              )
            else if (state.amenities.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text(
                  'الخدمات غير متاحة حاليًا',
                  style: TextStyle(
                    color: const Color(0xFF77879A),
                    fontSize: 11.sp,
                  ),
                ),
              )
            else
              ...groupedAmenities.entries.map(
                (entry) => _AmenityGroup(
                  category: entry.key,
                  amenities: entry.value,
                  selectedAmenities: selectedAmenities,
                  onChanged: onChanged,
                ),
              ),
          ],
        );
      },
    );
  }

  Map<String, List<AmenityModel>> _groupAmenities(
    List<AmenityModel> amenities,
  ) {
    final grouped = <String, List<AmenityModel>>{};
    for (final amenity in amenities) {
      final category = amenity.category ?? 'Other';
      grouped.putIfAbsent(category, () => []).add(amenity);
    }
    return grouped;
  }
}

class _AmenityGroup extends StatelessWidget {
  const _AmenityGroup({
    required this.category,
    required this.amenities,
    required this.selectedAmenities,
    required this.onChanged,
  });

  final String category;
  final List<AmenityModel> amenities;
  final Set<String> selectedAmenities;
  final void Function(AmenityModel amenity, bool selected) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            amenityCategoryArabicName(category),
            style: TextStyle(
              color: const Color(0xFF73849A),
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5.h),
          Wrap(
            spacing: 7.w,
            runSpacing: 2.h,
            children: amenities.map((amenity) {
              final selected = selectedAmenities.contains(amenity.name);
              return FilterChip(
                selected: selected,
                onSelected: (value) => onChanged(amenity, value),
                avatar: Icon(
                  amenityIcon(amenity.icon),
                  size: 15.sp,
                  color: selected
                      ? const Color(0xFF0B67C8)
                      : const Color(0xFF77899D),
                ),
                label: Text(amenityArabicName(amenity)),
                selectedColor: const Color(0xFFEAF3FF),
                backgroundColor: Colors.white,
                checkmarkColor: const Color(0xFF0B67C8),
                side: BorderSide(
                  color: selected
                      ? const Color(0xFF8BBDF0)
                      : const Color(0xFFE3E9F0),
                ),
                labelStyle: TextStyle(
                  color: selected
                      ? const Color(0xFF0B67C8)
                      : const Color(0xFF596D83),
                  fontSize: 10.sp,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
