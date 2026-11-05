import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/features/booking_requests/data/models/booking_request_model.dart';

class BookingRequestDetailsContent extends StatelessWidget {
  const BookingRequestDetailsContent({required this.booking, super.key});

  final BookingRequestModel booking;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        _DetailsCard(
          title: booking.property?.title ?? 'السكن',
          children: [
            _DetailLine(label: 'الغرفة', value: booking.room?.name),
            _DetailLine(label: 'الحالة', value: _statusLabel(booking.status)),
            _DetailLine(label: 'الرسالة', value: booking.message),
            if (booking.rejectionReason case final reason?)
              _DetailLine(label: 'سبب الرفض', value: reason),
            if (booking.createdAt case final createdAt?)
              _DetailLine(label: 'تاريخ الطلب', value: _formatDate(createdAt)),
            if (booking.updatedAt case final updatedAt?)
              _DetailLine(label: 'آخر تحديث', value: _formatDate(updatedAt)),
          ],
        ),
      ],
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: const Color(0xFF1D3553),
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 12.h),
          ...children,
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final displayValue = value;
    if (displayValue == null || displayValue.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 94.w,
            child: Text(
              label,
              style: TextStyle(color: const Color(0xFF8190A1), fontSize: 12.sp),
            ),
          ),
          Expanded(
            child: Text(
              displayValue,
              style: TextStyle(
                color: const Color(0xFF344C68),
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _statusLabel(String? status) => switch (status?.toUpperCase()) {
  'PENDING' => 'قيد المراجعة',
  'APPROVED' => 'مقبول',
  'REJECTED' => 'مرفوض',
  'CANCELLED' => 'ملغي',
  _ => status ?? 'غير محدد',
};

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
