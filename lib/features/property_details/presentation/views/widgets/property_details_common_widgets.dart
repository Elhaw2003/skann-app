import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PropertySectionCard extends StatelessWidget {
  const PropertySectionCard({required this.child, this.title, super.key});

  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19.r),
        border: Border.all(color: const Color(0xFFE7ECF3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF17385F).withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: TextStyle(
                color: const Color(0xFF1D3553),
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 12.h),
          ],
          child,
        ],
      ),
    );
  }
}

class PropertyTag extends StatelessWidget {
  const PropertyTag({
    required this.icon,
    required this.label,
    this.iconColor = const Color(0xFF0B67C8),
    super.key,
  });

  final IconData icon;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6FC),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15.sp, color: iconColor),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFF52657B),
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class PropertyInfoLine extends StatelessWidget {
  const PropertyInfoLine({
    required this.icon,
    required this.text,
    this.color = const Color(0xFF73849A),
    super.key,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17.sp, color: color),
        SizedBox(width: 7.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: color, fontSize: 11.sp, height: 1.45),
          ),
        ),
      ],
    );
  }
}

class PropertyAmenityChip extends StatelessWidget {
  const PropertyAmenityChip({required this.label, this.icon, super.key});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FB),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14.sp, color: const Color(0xFF0B67C8)),
            SizedBox(width: 5.w),
          ],
          Text(
            label,
            style: TextStyle(color: const Color(0xFF52657B), fontSize: 10.sp),
          ),
        ],
      ),
    );
  }
}

bool hasPropertyText(String? value) => value != null && value.trim().isNotEmpty;

Uri? validPropertyImageUri(String? value) {
  if (!hasPropertyText(value)) return null;
  final uri = Uri.tryParse(value!);
  if (uri == null ||
      !uri.hasAuthority ||
      (uri.scheme != 'http' && uri.scheme != 'https')) {
    return null;
  }
  return uri;
}
