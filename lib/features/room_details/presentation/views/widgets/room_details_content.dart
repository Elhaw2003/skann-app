import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/features/home/data/models/property_model.dart';
import 'package:skann_app/features/home/presentation/views/widgets/amenity_icon_mapping.dart';
import 'package:skann_app/features/home/presentation/views/widgets/property_card_labels.dart';
import 'package:skann_app/features/property_details/presentation/views/widgets/property_details_common_widgets.dart';
import 'package:skann_app/features/room_details/presentation/views/widgets/room_details_gallery.dart';

class RoomDetailsContent extends StatelessWidget {
  const RoomDetailsContent({required this.room, super.key});

  final PropertyRoomModel room;

  @override
  Widget build(BuildContext context) {
    final property = room.property;
    final propertyLocation = [
      property?.area,
      property?.city,
      property?.address,
    ].where(hasPropertyText).whereType<String>().toList();

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: RoomDetailsGallery(images: room.images)),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 28.h),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _RoomSummary(room: room),
              if (hasPropertyText(room.description)) ...[
                SizedBox(height: 12.h),
                _DescriptionSection(description: room.description!),
              ],
              if (_hasAmenities(room.amenities)) ...[
                SizedBox(height: 12.h),
                _AmenitiesSection(amenities: room.amenities),
              ],
              if (_hasPropertyInformation(property, propertyLocation)) ...[
                SizedBox(height: 12.h),
                _PropertySection(
                  property: property!,
                  location: propertyLocation,
                ),
              ],
            ]),
          ),
        ),
      ],
    );
  }
}

class _RoomSummary extends StatelessWidget {
  const _RoomSummary({required this.room});

  final PropertyRoomModel room;

  @override
  Widget build(BuildContext context) {
    return PropertySectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hasPropertyText(room.name) ? room.name! : 'تفاصيل الغرفة',
            style: TextStyle(
              color: const Color(0xFF1D3553),
              fontSize: 21.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (room.availableBeds != null) ...[
            SizedBox(height: 12.h),
            _AvailabilityBadge(availableBeds: room.availableBeds!),
          ],
          if (room.monthlyPrice != null) ...[
            SizedBox(height: 14.h),
            Text(
              '${propertyPriceText(room.monthlyPrice!)} ${propertyCurrencyLabel(null)} شهريًا',
              style: TextStyle(
                color: const Color(0xFF0B67C8),
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          if (room.capacity != null ||
              room.occupiedBeds != null ||
              room.availableBeds != null) ...[
            SizedBox(height: 14.h),
            PropertyInfoLine(
              icon: Icons.bed_outlined,
              text: [
                if (room.capacity != null) 'السعة ${room.capacity}',
                if (room.occupiedBeds != null)
                  '${room.occupiedBeds} سرير مشغول',
                if (room.availableBeds != null)
                  '${room.availableBeds} أماكن متاحة',
              ].join('  ·  '),
            ),
          ],
        ],
      ),
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return PropertySectionCard(
      title: 'عن الغرفة',
      child: Text(
        description,
        style: TextStyle(
          color: const Color(0xFF66788D),
          fontSize: 13.sp,
          height: 1.7,
        ),
      ),
    );
  }
}

class _AmenitiesSection extends StatelessWidget {
  const _AmenitiesSection({required this.amenities});

  final List<PropertyAmenityModel> amenities;

  @override
  Widget build(BuildContext context) {
    return PropertySectionCard(
      title: 'مميزات الغرفة',
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: amenities
            .where((amenity) => hasPropertyText(amenity.name))
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

class _PropertySection extends StatelessWidget {
  const _PropertySection({required this.property, required this.location});

  final PropertyRoomPropertyModel property;
  final List<String> location;

  @override
  Widget build(BuildContext context) {
    return PropertySectionCard(
      title: 'موقع السكن',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasPropertyText(property.title))
            Text(
              property.title!,
              style: TextStyle(
                color: const Color(0xFF1D3553),
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          if (location.isNotEmpty) ...[
            if (hasPropertyText(property.title)) SizedBox(height: 9.h),
            PropertyInfoLine(
              icon: Icons.location_on_outlined,
              text: location.join('، '),
            ),
          ],
          if (hasPropertyText(property.genderPolicy)) ...[
            SizedBox(height: 9.h),
            PropertyTag(
              icon: Icons.people_alt_outlined,
              label: genderPolicyLabel(property.genderPolicy!),
            ),
          ],
        ],
      ),
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({required this.availableBeds});

  final int availableBeds;

  @override
  Widget build(BuildContext context) {
    final isFull = availableBeds == 0;
    final color = isFull ? const Color(0xFFB54747) : const Color(0xFF16835D);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isFull ? Icons.event_busy_rounded : Icons.check_circle_outline,
          color: color,
          size: 17.sp,
        ),
        SizedBox(width: 6.w),
        Text(
          isFull ? 'مكتملة' : '$availableBeds أماكن متاحة',
          style: TextStyle(
            color: color,
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

bool _hasAmenities(List<PropertyAmenityModel> amenities) =>
    amenities.any((amenity) => hasPropertyText(amenity.name));

bool _hasPropertyInformation(
  PropertyRoomPropertyModel? property,
  List<String> location,
) =>
    property != null &&
    (hasPropertyText(property.title) || location.isNotEmpty);
