import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skann_app/core/routing/app_routes.dart';

class FavoritesEmptyView extends StatelessWidget {
  const FavoritesEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(28.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 104.w,
              height: 104.w,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF3FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                color: const Color(0xFF4F86C6),
                size: 49.sp,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'لسه مفيش أماكن سكن في المفضلة',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF1D3553),
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'احفظ الأماكن اللي تعجبك عشان تقدر ترجع لها بسهولة.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF77889C),
                fontSize: 12.sp,
                height: 1.6,
              ),
            ),
            SizedBox(height: 20.h),
            FilledButton.icon(
              onPressed: () => context.go(AppRoutes.studentHome),
              icon: const Icon(Icons.explore_outlined),
              label: const Text('استكشف أماكن السكن'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0B67C8),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 13.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FavoritesLoadingView extends StatelessWidget {
  const FavoritesLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        Container(
          height: 104.h,
          decoration: BoxDecoration(
            color: const Color(0xFFE7EEF6),
            borderRadius: BorderRadius.circular(24.r),
          ),
        ),
        SizedBox(height: 16.h),
        for (var index = 0; index < 3; index++) ...[
          const _FavoriteSkeletonCard(),
          SizedBox(height: 14.h),
        ],
      ],
    );
  }
}

class _FavoriteSkeletonCard extends StatelessWidget {
  const _FavoriteSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 268.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: const Color(0xFFE5EBF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 160.h,
            decoration: BoxDecoration(
              color: const Color(0xFFE7EEF6),
              borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              children: [
                _SkeletonLine(width: double.infinity, height: 14.h),
                SizedBox(height: 10.h),
                _SkeletonLine(width: 180.w, height: 10.h),
                SizedBox(height: 15.h),
                Row(
                  children: [
                    _SkeletonLine(width: 82.w, height: 23.h),
                    SizedBox(width: 8.w),
                    _SkeletonLine(width: 92.w, height: 23.h),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: const Color(0xFFE7EEF6),
      borderRadius: BorderRadius.circular(10.r),
    ),
  );
}

class FavoritesFailureView extends StatelessWidget {
  const FavoritesFailureView({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(28.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 48.sp,
            color: const Color(0xFFB54747),
          ),
          SizedBox(height: 14.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: const Color(0xFF52657B), fontSize: 13.sp),
          ),
          SizedBox(height: 16.h),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    ),
  );
}

class InlineFavoritesError extends StatelessWidget {
  const InlineFavoritesError({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
    child: Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2F0),
        borderRadius: BorderRadius.circular(13.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: const Color(0xFF9F3F3F), fontSize: 11.sp),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('حاول تاني')),
        ],
      ),
    ),
  );
}
