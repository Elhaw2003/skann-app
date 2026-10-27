import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RoomDetailsLoadingView extends StatelessWidget {
  const RoomDetailsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF0B67C8)),
    );
  }
}

class RoomDetailsErrorView extends StatelessWidget {
  const RoomDetailsErrorView({
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
            Icon(
              Icons.bedroom_parent_outlined,
              size: 52.sp,
              color: const Color(0xFF9AAFC5),
            ),
            SizedBox(height: 14.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: const Color(0xFF52657B), fontSize: 14.sp),
            ),
            SizedBox(height: 18.h),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0B67C8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
