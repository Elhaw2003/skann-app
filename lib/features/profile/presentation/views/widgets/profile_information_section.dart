import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileField {
  const ProfileField({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}

class ProfileInformationSection extends StatelessWidget {
  const ProfileInformationSection({
    required this.title,
    required this.icon,
    required this.fields,
    this.accentColor = const Color(0xFF176FC1),
    super.key,
  });

  final String title;
  final IconData icon;
  final List<ProfileField> fields;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    if (fields.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 15.h, 16.w, 7.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: const Color(0xFFE8EDF4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  color: const Color(0xFF20344F),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ...fields.map(
            (field) => Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 35.w,
                    height: 35.w,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(field.icon, color: accentColor, size: 18.sp),
                  ),
                  SizedBox(width: 11.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          field.label,
                          style: TextStyle(
                            color: const Color(0xFF8290A2),
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          field.value,
                          style: TextStyle(
                            color: const Color(0xFF263B55),
                            fontSize: 12.sp,
                            height: 1.4,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
