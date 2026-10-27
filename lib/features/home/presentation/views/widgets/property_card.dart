import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/core/theme/app_colors.dart';
import 'package:skann_app/features/home/data/models/property_model.dart';
import 'package:skann_app/features/home/presentation/views/widgets/property_card_image.dart';
import 'package:skann_app/features/home/presentation/views/widgets/property_card_info_pill.dart';
import 'package:skann_app/features/home/presentation/views/widgets/property_card_labels.dart';

class PropertyCard extends StatelessWidget {
  const PropertyCard({required this.property, super.key});

  final PropertyModel property;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21.r),
        border: Border.all(color: const Color(0xFFE7ECF3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF17385F).withValues(alpha: 0.055),
            blurRadius: 19,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PropertyCardImage(property: property),
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTitleAndRating(),
                if (_locationLabel.isNotEmpty) ...[
                  SizedBox(height: 7.h),
                  _buildLocation(),
                ],
                SizedBox(height: 12.h),
                _buildTypeAndPrice(),
                if (property.amenities.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Divider(height: 1.h, color: const Color(0xFFEEF1F5)),
                  SizedBox(height: 10.h),
                  _buildAmenities(),
                ],
                if (property.distanceFromUniversity != null) ...[
                  SizedBox(height: 9.h),
                  _buildUniversityDistance(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleAndRating() {
    return Row(
      children: [
        Expanded(
          child: Text(
            property.title ?? 'سكن طلابي',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF1D3553),
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (property.rating != null) ...[
          Icon(Icons.star_rounded, size: 17.sp, color: AppColors.starColore),
          SizedBox(width: 3.w),
          Text(
            property.rating!.toStringAsFixed(1),
            style: TextStyle(
              color: const Color(0xFF52657B),
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLocation() {
    return Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          size: 15.sp,
          color: const Color(0xFF73849A),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            _locationLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: const Color(0xFF73849A), fontSize: 10.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeAndPrice() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: [
              if (property.propertyType != null)
                PropertyCardInfoPill(
                  icon: Icons.apartment_rounded,
                  label: propertyTypeLabel(property.propertyType!),
                  color: const Color(0xFFEDF5FF),
                ),
              if (property.genderPolicy != null)
                PropertyCardInfoPill(
                  icon: Icons.people_alt_outlined,
                  label: genderPolicyLabel(property.genderPolicy!),
                  color: const Color(0xFFF2F0FF),
                ),
              if (property.availableRooms != null)
                PropertyCardInfoPill(
                  icon: Icons.bed_outlined,
                  label: '${property.availableRooms} غرف متاحة',
                  color: const Color(0xFFEAF8F2),
                ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        if (property.startingPrice != null) _buildPrice(),
      ],
    );
  }

  Widget _buildPrice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'يبدأ من',
          style: TextStyle(color: const Color(0xFF8794A5), fontSize: 9.sp),
        ),
        SizedBox(height: 2.h),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: propertyPriceText(property.startingPrice!),
                style: TextStyle(
                  color: const Color(0xFF0B67C8),
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextSpan(
                text: ' ${propertyCurrencyLabel(property.currency)}',
                style: TextStyle(
                  color: const Color(0xFF66788D),
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmenities() {
    return Wrap(
      spacing: 12.w,
      runSpacing: 6.h,
      children: property.amenities.take(3).map((amenity) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              propertyAmenityIcon(amenity.icon ?? amenity.name ?? ''),
              size: 13.sp,
              color: const Color(0xFF8293A6),
            ),
            SizedBox(width: 4.w),
            Text(
              amenity.name ?? '',
              style: TextStyle(color: const Color(0xFF74859A), fontSize: 9.sp),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildUniversityDistance() {
    return Row(
      children: [
        Icon(
          Icons.school_outlined,
          size: 14.sp,
          color: const Color(0xFF0B67C8),
        ),
        SizedBox(width: 5.w),
        Expanded(
          child: Text(
            property.distanceFromUniversity ?? '',
            style: TextStyle(color: const Color(0xFF55718F), fontSize: 10.sp),
          ),
        ),
      ],
    );
  }

  String get _locationLabel => [
    property.area,
    property.city,
  ].where((value) => value != null && value.isNotEmpty).join('، ');
}
