import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/core/theme/app_colors.dart';
import 'package:skann_app/core/theme/app_text_styles.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h, bottom: 18.h),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              Icons.home_work_rounded,
              color: AppColors.whiteColor,
              size: 25.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'سكن',
                  style: AppTextStyles.primaryTextW600S22.copyWith(
                    color: const Color(0xFF17385F),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'بيتك الجامعي أقرب مما تتخيل',
                  style: AppTextStyles.splashSubtitle.copyWith(fontSize: 11.sp),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.explore_outlined,
                  color: AppColors.primaryColor,
                  size: 17.sp,
                ),
                SizedBox(width: 5.w),
                Text(
                  'اكتشف',
                  style: TextStyle(
                    color: AppColors.secondaryColor,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
