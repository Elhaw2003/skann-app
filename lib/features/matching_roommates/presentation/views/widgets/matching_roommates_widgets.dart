import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/core/theme/app_colors.dart';

class MatchingRoommatesHeader extends StatelessWidget {
  const MatchingRoommatesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(17.w, 18.h, 17.w, 17.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE8EDF4)),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FC),
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Icon(
              Icons.people_alt_outlined,
              color: AppColors.primaryColor,
              size: 25.sp,
            ),
          ),
          SizedBox(width: 13.w),
          Expanded(
            child: Text(
              'اكتشف الطلاب الذين تتوافق بياناتهم الدراسية وموقعهم مع ملفك الشخصي.',
              style: TextStyle(
                color: const Color(0xFF52647A),
                fontSize: 12.sp,
                height: 1.65,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MatchingRoommatesEmptyState extends StatelessWidget {
  const MatchingRoommatesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 38.h),
      child: const MatchingRoommatesStatus(
        icon: Icons.people_outline_rounded,
        title: 'لا يوجد زملاء سكن مطابقون حتى الآن',
        message: 'أكمل بيانات ملفك الشخصي لتحسين نتائج المطابقة.',
      ),
    );
  }
}

class MatchingRoommatesStatus extends StatelessWidget {
  const MatchingRoommatesStatus({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE8EDF4)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 42.sp, color: AppColors.primaryColor),
          SizedBox(height: 12.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF20344F),
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 7.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF71809A),
              fontSize: 12.sp,
              height: 1.6,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: 16.h),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
              ),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class MatchingRoommatesInlineError extends StatelessWidget {
  const MatchingRoommatesInlineError({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(11.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F0),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        message,
        style: TextStyle(color: const Color(0xFFB42318), fontSize: 11.sp),
      ),
    );
  }
}

class MatchingRoommatesPaginationFooter extends StatelessWidget {
  const MatchingRoommatesPaginationFooter({
    required this.isLoading,
    required this.onRetry,
    this.error,
    super.key,
  });

  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 18.h),
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primaryColor,
          ),
        ),
      );
    }
    if (error == null) return SizedBox(height: 8.h);

    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: Column(
        children: [
          MatchingRoommatesInlineError(message: error!),
          TextButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
        ],
      ),
    );
  }
}
