import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/features/home/data/models/property_model.dart';
import 'package:skann_app/features/home/presentation/views/widgets/property_card_labels.dart';

class PropertyCardImage extends StatelessWidget {
  const PropertyCardImage({required this.property, super.key});

  final PropertyModel property;

  @override
  Widget build(BuildContext context) {
    final imageUri = property.thumbnailUri;
    return SizedBox(
      height: 176.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUri == null)
            const PropertyImagePlaceholder()
          else
            Image.network(
              imageUri.toString(),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const PropertyImagePlaceholder(),
            ),
          PositionedDirectional(
            top: 11.h,
            start: 11.w,
            child: Wrap(
              spacing: 6.w,
              children: [
                if (property.propertyType != null)
                  PropertyImageBadge(
                    label: propertyTypeLabel(property.propertyType!),
                  ),
                if (property.isVerified == true)
                  const PropertyImageBadge(
                    label: 'موثّق',
                    icon: Icons.verified_rounded,
                    color: Color(0xFF0B67C8),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PropertyImagePlaceholder extends StatelessWidget {
  const PropertyImagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEAF1F8),
      child: Center(
        child: Icon(
          Icons.home_work_outlined,
          size: 42.sp,
          color: const Color(0xFF9AAFC5),
        ),
      ),
    );
  }
}

class PropertyImageBadge extends StatelessWidget {
  const PropertyImageBadge({
    required this.label,
    this.icon,
    this.color = const Color(0xFF344A62),
    super.key,
  });

  final String label;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.91),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12.sp, color: Colors.white),
            SizedBox(width: 4.w),
          ],
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
