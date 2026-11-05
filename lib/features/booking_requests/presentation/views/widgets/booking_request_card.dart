import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/features/booking_requests/data/models/booking_request_model.dart';

class BookingRequestCard extends StatelessWidget {
  const BookingRequestCard({
    required this.booking,
    required this.onTap,
    required this.onCancel,
    this.isCancelling = false,
    super.key,
  });

  final BookingRequestModel booking;
  final VoidCallback onTap;
  final VoidCallback onCancel;
  final bool isCancelling;

  @override
  Widget build(BuildContext context) {
    final propertyTitle = booking.property?.title ?? 'طلب حجز';
    final roomName = booking.room?.name;
    final createdAt = booking.createdAt;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.all(15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      propertyTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF1D3553),
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  BookingStatusBadge(status: booking.status),
                ],
              ),
              if (roomName != null && roomName.trim().isNotEmpty) ...[
                SizedBox(height: 7.h),
                Text(
                  roomName,
                  style: TextStyle(
                    color: const Color(0xFF65778D),
                    fontSize: 12.sp,
                  ),
                ),
              ],
              if (createdAt != null) ...[
                SizedBox(height: 10.h),
                Text(
                  'تاريخ الطلب: ${_formatDate(createdAt)}',
                  style: TextStyle(
                    color: const Color(0xFF8794A4),
                    fontSize: 11.sp,
                  ),
                ),
              ],
              if (booking.status == 'PENDING') ...[
                SizedBox(height: 8.h),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton.icon(
                    onPressed: isCancelling ? null : onCancel,
                    icon: isCancelling
                        ? SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.cancel_outlined),
                    label: const Text('إلغاء طلب الحجز'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFB54747),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class BookingStatusBadge extends StatelessWidget {
  const BookingStatusBadge({required this.status, super.key});

  final String? status;

  @override
  Widget build(BuildContext context) {
    final (label, color, background) = switch (status?.toUpperCase()) {
      'PENDING' => (
        'قيد المراجعة',
        const Color(0xFFAD7413),
        const Color(0xFFFFF3D8),
      ),
      'APPROVED' => ('مقبول', const Color(0xFF16835D), const Color(0xFFE5F6EF)),
      'REJECTED' => ('مرفوض', const Color(0xFFB54747), const Color(0xFFFFEAEA)),
      'CANCELLED' => ('ملغي', const Color(0xFF58697E), const Color(0xFFF0F3F7)),
      _ => (
        status ?? 'غير محدد',
        const Color(0xFF58697E),
        const Color(0xFFF0F3F7),
      ),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
