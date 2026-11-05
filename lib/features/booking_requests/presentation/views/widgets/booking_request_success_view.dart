import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skann_app/core/routing/app_routes.dart';
import 'package:skann_app/features/booking_requests/data/models/booking_request_model.dart';

class BookingRequestSuccessView extends StatelessWidget {
  const BookingRequestSuccessView({required this.booking, super.key});

  final BookingRequestModel booking;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(28.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76.w,
              height: 76.w,
              decoration: const BoxDecoration(
                color: Color(0xFFE5F6EF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                color: const Color(0xFF16835D),
                size: 44.sp,
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              'تم إرسال طلب الحجز بنجاح',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF1D3553),
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'يمكنك متابعة حالة طلبك من قسم حجوزاتي.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF738398),
                fontSize: 13.sp,
              ),
            ),
            if (booking.status != null) ...[
              SizedBox(height: 10.h),
              Text(
                'حالة الطلب: ${booking.status}',
                style: TextStyle(
                  color: const Color(0xFF52657B),
                  fontSize: 12.sp,
                ),
              ),
            ],
            SizedBox(height: 22.h),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.go(AppRoutes.myBookings),
                child: const Text('الذهاب إلى حجوزاتي'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
