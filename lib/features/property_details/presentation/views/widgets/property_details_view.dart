import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/features/home/data/models/property_model.dart';
import 'package:skann_app/features/property_details/presentation/cubit/property_details_cubit.dart';
import 'package:skann_app/features/property_details/presentation/cubit/property_details_state.dart';
import 'package:skann_app/features/property_details/presentation/views/widgets/property_details_gallery.dart';
import 'package:skann_app/features/property_details/presentation/views/widgets/property_details_overview_section.dart';
import 'package:skann_app/features/property_details/presentation/views/widgets/property_details_people_section.dart';
import 'package:skann_app/features/property_details/presentation/views/widgets/property_details_rooms_section.dart';

class PropertyDetailsView extends StatelessWidget {
  const PropertyDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FB),
        body: SafeArea(
          child: BlocBuilder<PropertyDetailsCubit, PropertyDetailsState>(
            builder: (context, state) {
              return switch (state.status) {
                PropertyDetailsStatus.initial ||
                PropertyDetailsStatus.loading => const _DetailsLoadingView(),
                PropertyDetailsStatus.failure => _DetailsFailureView(
                  message: state.errorMessage ?? 'تعذر تحميل تفاصيل السكن.',
                  onRetry: () {
                    final id = state.propertyId;
                    if (id != null) {
                      context.read<PropertyDetailsCubit>().loadPropertyDetails(
                        id,
                      );
                    }
                  },
                ),
                PropertyDetailsStatus.loaded => _DetailsContent(
                  property: state.property!,
                  isRefreshing: state.isRefreshing,
                  onRefresh: context.read<PropertyDetailsCubit>().refresh,
                ),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _DetailsLoadingView extends StatelessWidget {
  const _DetailsLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Color(0xFF0B67C8)),
          SizedBox(height: 14),
          Text('بنحمّل تفاصيل السكن...'),
        ],
      ),
    );
  }
}

class _DetailsFailureView extends StatelessWidget {
  const _DetailsFailureView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.home_work_outlined,
              size: 52.sp,
              color: const Color(0xFF9AAFC5),
            ),
            SizedBox(height: 14.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: const Color(0xFF52657B), fontSize: 14.sp),
            ),
            SizedBox(height: 18.h),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0B67C8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsContent extends StatelessWidget {
  const _DetailsContent({
    required this.property,
    required this.isRefreshing,
    required this.onRefresh,
  });

  final PropertyModel property;
  final bool isRefreshing;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: const Color(0xFF0B67C8),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: PropertyDetailsGallery(images: property.images),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 28.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (isRefreshing)
                  const LinearProgressIndicator(
                    minHeight: 2,
                    color: Color(0xFF0B67C8),
                  ),
                PropertyOverviewSection(property: property),
                if (_hasText(property.description)) ...[
                  SizedBox(height: 12.h),
                  PropertyDescriptionSection(
                    description: property.description!,
                  ),
                ],
                if (property.amenities.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  PropertyAmenitiesSection(amenities: property.amenities),
                ],
                if (property.rooms.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  PropertyRoomsSection(
                    rooms: property.rooms,
                    currency: property.currency,
                  ),
                ],
                if (property.currentResidents.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  PropertyResidentsSection(
                    residents: property.currentResidents,
                  ),
                ],
                if (_hasOwner(property.owner)) ...[
                  SizedBox(height: 12.h),
                  PropertyOwnerSection(owner: property.owner!),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

bool _hasOwner(PropertyOwnerModel? owner) =>
    owner != null && (_hasText(owner.name) || _hasText(owner.profileImage));
