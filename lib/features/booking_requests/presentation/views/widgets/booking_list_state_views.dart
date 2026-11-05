import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/features/booking_requests/presentation/cubit/booking_requests_states.dart';

class BookingListLoadingView extends StatelessWidget {
  const BookingListLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF0B67C8)),
    );
  }
}

class BookingListErrorView extends StatelessWidget {
  const BookingListErrorView({
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
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 42,
              color: Color(0xFFB54747),
            ),
            SizedBox(height: 12.h),
            Text(message, textAlign: TextAlign.center),
            SizedBox(height: 12.h),
            FilledButton(
              onPressed: onRetry,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyBookingsView extends StatelessWidget {
  const EmptyBookingsView({required this.filter, super.key});

  final BookingStatusFilter filter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(28.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note_rounded,
              size: 54.sp,
              color: const Color(0xFF9BAABC),
            ),
            SizedBox(height: 14.h),
            Text(
              filter == BookingStatusFilter.all
                  ? 'لا توجد طلبات حجز حتى الآن'
                  : 'لا توجد طلبات ${filter.label}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF52657B),
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'عندما ترسل طلب حجز، ستظهر تفاصيله هنا',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF8593A4),
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InlineBookingError extends StatelessWidget {
  const InlineBookingError({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2F0),
        borderRadius: BorderRadius.circular(12.r),
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
    );
  }
}
