import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/features/home/data/models/property_model.dart';

class BookingSelectionSummary extends StatelessWidget {
  const BookingSelectionSummary({required this.property, required this.room, super.key});

  final PropertyRoomPropertyModel property;
  final PropertyRoomModel room;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(17.w),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FF),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: const Icon(
              Icons.apartment_rounded,
              color: Color(0xFF0B67C8),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.title ?? 'السكن المختار',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF1D3553),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  room.name ?? 'الغرفة المختارة',
                  style: TextStyle(
                    color: const Color(0xFF62768E),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BookingRequestMessageForm extends StatelessWidget {
  const BookingRequestMessageForm({
    required this.controller,
    required this.isSubmitting,
    required this.onSubmit,
    this.errorMessage,
    super.key,
  });

  final TextEditingController controller;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(17.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'رسالة لصاحب السكن',
            style: TextStyle(
              color: const Color(0xFF1D3553),
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'اكتب رسالتك المرفقة بطلب الحجز.',
            style: TextStyle(color: const Color(0xFF7C8A9B), fontSize: 12.sp),
          ),
          SizedBox(height: 14.h),
          TextField(
            controller: controller,
            minLines: 4,
            maxLines: 6,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: 'اكتب رسالتك هنا',
              alignLabelWithHint: true,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: const BorderSide(color: Color(0xFFE1E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: const BorderSide(color: Color(0xFFE1E8F0)),
              ),
            ),
          ),
          if (errorMessage case final message?) ...[
            SizedBox(height: 12.h),
            BookingSubmissionError(message: message, onRetry: onSubmit),
          ],
          SizedBox(height: 18.h),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isSubmitting ? null : onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0B67C8),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: isSubmitting
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('إرسال طلب الحجز'),
            ),
          ),
        ],
      ),
    );
  }
}

class BookingSubmissionError extends StatelessWidget {
  const BookingSubmissionError({
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
              style: TextStyle(
                color: const Color(0xFF9F3F3F),
                fontSize: 12.sp,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
        ],
      ),
    );
  }
}
