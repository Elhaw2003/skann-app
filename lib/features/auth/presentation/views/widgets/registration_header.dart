import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/core/theme/app_text_styles.dart';

class RegistrationHeader extends StatelessWidget {
  const RegistrationHeader({required this.isStudent, super.key});

  final bool isStudent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0877E8), Color(0xFF0646A8)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0646A8).withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Text(
              'سكنك الجامعي يبدأ من هنا',
              style: AppTextStyles.whiteW500S17.copyWith(fontSize: 11.sp),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            isStudent ? 'انضم لمجتمع سكن الطلاب' : 'أضف سكنك إلى مجتمع سكن',
            textAlign: TextAlign.center,
            style: AppTextStyles.whiteW500S22.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            isStudent
                ? 'أنشئ حسابك واعثر على سكن قريب من جامعتك'
                : 'أنشئ حسابك وابدأ في استقبال الطلاب',
            textAlign: TextAlign.center,
            style: AppTextStyles.whiteW500S17.copyWith(
              fontSize: 12.sp,
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }
}
