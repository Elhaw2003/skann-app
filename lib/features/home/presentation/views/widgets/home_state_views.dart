import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/core/theme/app_colors.dart';

class HomeLoadingView extends StatelessWidget {
  const HomeLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 24.h),
      children: [
        Row(
          children: [
            _Skeleton(width: 48.w, height: 48.h, radius: 16.r),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Skeleton(width: 90.w, height: 15.h, radius: 5.r),
                SizedBox(height: 8.h),
                _Skeleton(width: 155.w, height: 10.h, radius: 5.r),
              ],
            ),
          ],
        ),
        SizedBox(height: 23.h),
        _Skeleton(width: double.infinity, height: 54.h, radius: 17.r),
        SizedBox(height: 13.h),
        SizedBox(
          height: 40.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (context, index) => SizedBox(width: 8.w),
            itemBuilder: (context, index) =>
                _Skeleton(width: 83.w, height: 38.h, radius: 22.r),
          ),
        ),
        SizedBox(height: 25.h),
        _Skeleton(width: 145.w, height: 17.h, radius: 5.r),
        SizedBox(height: 14.h),
        const _PropertySkeleton(),
        SizedBox(height: 16.h),
        const _PropertySkeleton(),
      ],
    );
  }
}

class HomeFailureView extends StatelessWidget {
  const HomeFailureView({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StateIcon(
              icon: Icons.cloud_off_rounded,
              color: const Color(0xFFDE6B57),
            ),
            SizedBox(height: 18.h),
            Text(
              'مش قادرين نحمّل السكنات',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF263F5D),
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF77879A),
                fontSize: 11.sp,
                height: 1.6,
              ),
            ),
            SizedBox(height: 18.h),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('حاول تاني'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0B67C8),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeEmptyView extends StatelessWidget {
  const HomeEmptyView({required this.onResetFilters, super.key});

  final VoidCallback onResetFilters;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(26.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StateIcon(
              icon: Icons.search_off_rounded,
              color: const Color(0xFF5F95CE),
            ),
            SizedBox(height: 17.h),
            Text(
              'مفيش سكنات مطابقة لبحثك',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF263F5D),
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'جرّب تغيّر كلمة البحث أو تمسح الفلاتر',
              textAlign: TextAlign.center,
              style: TextStyle(color: const Color(0xFF77879A), fontSize: 11.sp),
            ),
            SizedBox(height: 16.h),
            OutlinedButton.icon(
              onPressed: onResetFilters,
              icon: const Icon(Icons.filter_alt_off_outlined),
              label: const Text('مسح الفلاتر'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0B67C8),
                side: const BorderSide(color: Color(0xFF9DC5ED)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeInlineError extends StatelessWidget {
  const HomeInlineError({
    required this.message,
    required this.actionLabel,
    required this.onAction,
    super.key,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F0),
        borderRadius: BorderRadius.circular(13.r),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.redAppColor,
            size: 18,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: const Color(0xFF9D5145), fontSize: 10.sp),
            ),
          ),
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel, style: TextStyle(fontSize: 10.sp)),
          ),
        ],
      ),
    );
  }
}

class _PropertySkeleton extends StatelessWidget {
  const _PropertySkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(11.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Skeleton(width: double.infinity, height: 155.h, radius: 15.r),
          SizedBox(height: 14.h),
          _Skeleton(width: 200.w, height: 15.h, radius: 5.r),
          SizedBox(height: 9.h),
          _Skeleton(width: 135.w, height: 11.h, radius: 5.r),
          SizedBox(height: 15.h),
          Row(
            children: [
              _Skeleton(width: 83.w, height: 25.h, radius: 8.r),
              SizedBox(width: 7.w),
              _Skeleton(width: 71.w, height: 25.h, radius: 8.r),
            ],
          ),
        ],
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({
    required this.width,
    required this.height,
    required this.radius,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE9EFF6),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _StateIcon extends StatelessWidget {
  const _StateIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76.w,
      height: 76.h,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 34.sp, color: color),
    );
  }
}
