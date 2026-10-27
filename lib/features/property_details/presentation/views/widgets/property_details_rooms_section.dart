import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skann_app/features/home/data/models/property_model.dart';
import 'package:skann_app/features/home/presentation/views/widgets/amenity_icon_mapping.dart';
import 'package:skann_app/features/home/presentation/views/widgets/property_card_labels.dart';
import 'package:skann_app/features/property_details/presentation/views/widgets/property_details_common_widgets.dart';

class PropertyRoomsSection extends StatelessWidget {
  const PropertyRoomsSection({required this.rooms, this.currency, super.key});

  final List<PropertyRoomModel> rooms;
  final String? currency;

  @override
  Widget build(BuildContext context) {
    return PropertySectionCard(
      title: 'الغرف والتوافر',
      child: Column(
        children: [
          for (var index = 0; index < rooms.length; index++) ...[
            if (index > 0) SizedBox(height: 10.h),
            _RoomCard(room: rooms[index], currency: currency),
          ],
        ],
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  const _RoomCard({required this.room, this.currency});

  final PropertyRoomModel room;
  final String? currency;

  @override
  Widget build(BuildContext context) {
    final imageUri = room.images.isEmpty
        ? null
        : validPropertyImageUri(room.images.first.url);
    final isFull = room.availableBeds == 0;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        border: Border.all(color: const Color(0xFFE9EFF5)),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (imageUri != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(11.r),
                  child: CachedNetworkImage(
                    imageUrl: imageUri.toString(),
                    width: 62.w,
                    height: 62.w,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const _RoomImagePlaceholder(),
                    errorWidget: (context, url, error) =>
                        const _RoomImagePlaceholder(),
                  ),
                )
              else
                const _RoomImagePlaceholder(),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasPropertyText(room.name) ? room.name! : 'غرفة',
                      style: TextStyle(
                        color: const Color(0xFF1D3553),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (room.availableBeds != null) ...[
                      SizedBox(height: 5.h),
                      _AvailabilityLabel(
                        availableBeds: room.availableBeds!,
                        isFull: isFull,
                      ),
                    ],
                  ],
                ),
              ),
              if (room.monthlyPrice != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${propertyPriceText(room.monthlyPrice!)} ${propertyCurrencyLabel(currency)}',
                      style: TextStyle(
                        color: const Color(0xFF0B67C8),
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'شهريًا',
                      style: TextStyle(
                        color: const Color(0xFF8794A5),
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (hasPropertyText(room.description)) ...[
            SizedBox(height: 10.h),
            Text(
              room.description!,
              style: TextStyle(
                color: const Color(0xFF66788D),
                fontSize: 12.sp,
                height: 1.5,
              ),
            ),
          ],
          if (room.capacity != null || room.occupiedBeds != null) ...[
            SizedBox(height: 10.h),
            PropertyInfoLine(
              icon: Icons.bed_outlined,
              text: [
                if (room.occupiedBeds != null) '${room.occupiedBeds} مشغول',
                if (room.capacity != null) 'السعة ${room.capacity}',
              ].join('  ·  '),
            ),
          ],
          if (room.amenities.any(
            (amenity) => hasPropertyText(amenity.name),
          )) ...[
            SizedBox(height: 9.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: room.amenities
                  .where((amenity) => hasPropertyText(amenity.name))
                  .map(
                    (amenity) => PropertyAmenityChip(
                      label: amenity.name!,
                      icon: amenityIcon(amenity.icon),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _RoomImagePlaceholder extends StatelessWidget {
  const _RoomImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62.w,
      height: 62.w,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1F8),
        borderRadius: BorderRadius.circular(11.r),
      ),
      child: Icon(
        Icons.bedroom_parent_outlined,
        color: const Color(0xFF8293A6),
        size: 25.sp,
      ),
    );
  }
}

class _AvailabilityLabel extends StatelessWidget {
  const _AvailabilityLabel({required this.availableBeds, required this.isFull});

  final int availableBeds;
  final bool isFull;

  @override
  Widget build(BuildContext context) {
    final color = isFull ? const Color(0xFFB54747) : const Color(0xFF16835D);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isFull ? Icons.event_busy_rounded : Icons.check_circle_outline,
          size: 14.sp,
          color: color,
        ),
        SizedBox(width: 4.w),
        Text(
          isFull ? 'مكتملة' : '$availableBeds أماكن متاحة',
          style: TextStyle(
            color: color,
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
