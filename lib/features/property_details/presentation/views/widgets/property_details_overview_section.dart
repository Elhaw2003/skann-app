import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/features/home/data/models/property_model.dart';
import 'package:skann_app/features/home/presentation/views/widgets/amenity_icon_mapping.dart';
import 'package:skann_app/features/home/presentation/views/widgets/property_card_labels.dart';
import 'package:skann_app/features/property_details/presentation/views/widgets/property_details_common_widgets.dart';

class PropertyOverviewSection extends StatelessWidget {
  const PropertyOverviewSection({required this.property, super.key});

  final PropertyModel property;

  @override
  Widget build(BuildContext context) {
    final locationParts = [
      property.location?.area ?? property.area,
      property.location?.city ?? property.city,
      property.location?.address ?? property.address,
    ].where(hasPropertyText).toList();

    return PropertySectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  property.title ?? 'سكن طلابي',
                  style: TextStyle(
                    color: const Color(0xFF1D3553),
                    fontSize: 21.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (property.isVerified == true) ...[
                SizedBox(width: 8.w),
                Icon(
                  Icons.verified_rounded,
                  color: const Color(0xFF0B67C8),
                  size: 23.sp,
                  semanticLabel: 'سكن موثّق',
                ),
              ],
            ],
          ),
          SizedBox(height: 11.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              if (hasPropertyText(property.propertyType))
                PropertyTag(
                  icon: Icons.apartment_rounded,
                  label: propertyTypeLabel(property.propertyType!),
                ),
              if (hasPropertyText(property.genderPolicy))
                PropertyTag(
                  icon: Icons.people_alt_outlined,
                  label: genderPolicyLabel(property.genderPolicy!),
                ),
              if (property.rating != null &&
                  property.rating! > 0 &&
                  property.reviewsCount != null &&
                  property.reviewsCount! > 0)
                PropertyTag(
                  icon: Icons.star_rounded,
                  label:
                      '${property.rating!.toStringAsFixed(1)}  ·  ${property.reviewsCount} تقييم',
                  iconColor: const Color(0xFFE3A900),
                ),
            ],
          ),
          if (locationParts.isNotEmpty) ...[
            SizedBox(height: 16.h),
            PropertyInfoLine(
              icon: Icons.location_on_outlined,
              text: locationParts.join('، '),
            ),
          ],
          if (hasPropertyText(property.distanceFromUniversity)) ...[
            SizedBox(height: 10.h),
            PropertyInfoLine(
              icon: Icons.school_outlined,
              text: property.distanceFromUniversity!,
              color: const Color(0xFF0B67C8),
            ),
          ],
          if (property.currentOccupants != null) ...[
            SizedBox(height: 10.h),
            PropertyInfoLine(
              icon: Icons.groups_2_outlined,
              text: '${property.currentOccupants} مقيم حاليًا',
            ),
          ],
        ],
      ),
    );
  }
}

class PropertyDescriptionSection extends StatefulWidget {
  const PropertyDescriptionSection({required this.description, super.key});

  final String description;

  @override
  State<PropertyDescriptionSection> createState() =>
      _PropertyDescriptionSectionState();
}

class _PropertyDescriptionSectionState
    extends State<PropertyDescriptionSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final canExpand = widget.description.length > 180;
    return PropertySectionCard(
      title: 'عن السكن',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.description,
            maxLines: canExpand && !_expanded ? 4 : null,
            overflow: canExpand && !_expanded ? TextOverflow.ellipsis : null,
            style: TextStyle(
              color: const Color(0xFF66788D),
              fontSize: 13.sp,
              height: 1.7,
            ),
          ),
          if (canExpand)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(_expanded ? 'عرض أقل' : 'اقرأ المزيد'),
              ),
            ),
        ],
      ),
    );
  }
}

class PropertyAmenitiesSection extends StatelessWidget {
  const PropertyAmenitiesSection({required this.amenities, super.key});

  final List<PropertyAmenityModel> amenities;

  @override
  Widget build(BuildContext context) {
    final visibleAmenities = amenities
        .where((amenity) => hasPropertyText(amenity.name))
        .toList();
    if (visibleAmenities.isEmpty) return const SizedBox.shrink();
    return PropertySectionCard(
      title: 'المميزات والخدمات',
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: visibleAmenities
            .map(
              (amenity) => PropertyAmenityChip(
                label: amenity.name!,
                icon: amenityIcon(amenity.icon),
              ),
            )
            .toList(),
      ),
    );
  }
}
