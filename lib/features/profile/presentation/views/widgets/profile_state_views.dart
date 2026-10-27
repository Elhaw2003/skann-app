import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/core/theme/app_colors.dart';

class ProfileLoadingView extends StatelessWidget {
  const ProfileLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 24.h),
      children: [
        Container(
          height: 25.h,
          width: 145.w,
          decoration: BoxDecoration(
            color: const Color(0xFFE1E8F0),
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        SizedBox(height: 19.h),
        Container(
          height: 245.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25.r),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 40.w,
                  height: 40.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.primaryColor,
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  'جاري تحميل بياناتك...',
                  style: TextStyle(
                    color: const Color(0xFF6D7D90),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 15.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 15.h,
                width: 110.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7ECF2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              SizedBox(height: 17.h),
              for (var index = 0; index < 2; index++) ...[
                Container(
                  height: 35.w,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F6F9),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                if (index == 0) SizedBox(height: 12.h),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class ProfileErrorView extends StatelessWidget {
  const ProfileErrorView({
    required this.message,
    required this.requiresLogin,
    required this.onRetry,
    required this.onLogin,
    super.key,
  });

  final String message;
  final bool requiresLogin;
  final VoidCallback onRetry;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Container(
          padding: EdgeInsets.all(22.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: const Color(0xFFE8EDF4)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 62.w,
                height: 62.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF1ED),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_off_rounded,
                  color: const Color(0xFFE07852),
                  size: 29.sp,
                ),
              ),
              SizedBox(height: 15.h),
              Text(
                'تعذر تحميل الملف الشخصي',
                style: TextStyle(
                  color: const Color(0xFF20344F),
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF718096),
                  fontSize: 12.sp,
                  height: 1.6,
                ),
              ),
              SizedBox(height: 18.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: FilledButton(
                  onPressed: requiresLogin ? onLogin : onRetry,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                  ),
                  child: Text(
                    requiresLogin ? 'تسجيل الدخول من جديد' : 'إعادة المحاولة',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileRefreshError extends StatelessWidget {
  const ProfileRefreshError({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4EC),
        borderRadius: BorderRadius.circular(13.r),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFD27B42),
            size: 18,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: const Color(0xFF895A39), fontSize: 11.sp),
            ),
          ),
        ],
      ),
    );
  }
}
