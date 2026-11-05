import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skann_app/core/routing/app_routes.dart';
import 'package:skann_app/features/favorites/presentation/widgets/favorite_button.dart';
import 'package:skann_app/features/home/data/models/property_model.dart';
import 'package:skann_app/features/home/presentation/views/widgets/property_card_image.dart';
import 'package:skann_app/features/home/presentation/views/widgets/property_card_info_pill.dart';
import 'package:skann_app/features/home/presentation/views/widgets/property_card_labels.dart';

class FavoritePropertyCard extends StatelessWidget {
  const FavoritePropertyCard({required this.property, super.key});

  final PropertyModel property;

  @override
  Widget build(BuildContext context) {
    final propertyId = property.id;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22.r),
      child: InkWell(
        onTap: propertyId == null || propertyId.trim().isEmpty
            ? null
            : () => context.push(
                AppRoutes.propertyDetails.replaceFirst(
                  ':propertyId',
                  Uri.encodeComponent(propertyId),
                ),
              ),
        borderRadius: BorderRadius.circular(22.r),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: const Color(0xFFE5EBF2)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1D3553).withValues(alpha: 0.045),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 170.h,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _PropertyImage(property: property),
                    PositionedDirectional(
                      top: 10.h,
                      end: 10.w,
                      child: FavoriteButton(property: property),
                    ),
                    if (property.propertyType != null)
                      PositionedDirectional(
                        top: 12.h,
                        start: 12.w,
                        child: PropertyImageBadge(
                          label: propertyTypeLabel(property.propertyType!),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 13.h, 14.w, 15.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      property.title ?? 'سكن طلابي',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF1D3553),
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (_location.isNotEmpty) ...[
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: const Color(0xFF7F90A4),
                            size: 15.sp,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              _location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: const Color(0xFF77889C),
                                fontSize: 11.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: 11.h),
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 6.h,
                      children: [
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
                    if (property.startingPrice != null) ...[
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Icon(
                            Icons.payments_outlined,
                            color: const Color(0xFF0B67C8),
                            size: 18.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'يبدأ من ',
                            style: TextStyle(
                              color: const Color(0xFF7D8DA1),
                              fontSize: 10.sp,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${formatFavoritePrice(property.startingPrice!)} ${propertyCurrencyLabel(property.currency)} / شهر',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: const Color(0xFF0B67C8),
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _location => [
    property.area,
    property.city,
  ].where((part) => part != null && part.trim().isNotEmpty).join('، ');
}

class _PropertyImage extends StatelessWidget {
  const _PropertyImage({required this.property});

  final PropertyModel property;

  @override
  Widget build(BuildContext context) {
    final uri = property.thumbnailUri;
    if (uri == null) return const PropertyImagePlaceholder();
    return CachedNetworkImage(
      imageUrl: uri.toString(),
      fit: BoxFit.cover,
      placeholder: (context, url) => const PropertyImagePlaceholder(),
      errorWidget: (context, url, error) => const PropertyImagePlaceholder(),
    );
  }
}

String formatFavoritePrice(num price) {
  final formatted = price % 1 == 0
      ? price.toInt().toString()
      : price.toStringAsFixed(2);
  final parts = formatted.split('.');
  final groupedInteger = parts.first.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return parts.length == 1 ? groupedInteger : '$groupedInteger.${parts.last}';
}
